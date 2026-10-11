[CmdletBinding()]
param(
  [string[]]$IncludePackage = @('vercel-agent-skills','taste-skill','playwright-cli'),
  [string]$PluginName = 'rogeriosbf-design-web',
  [string]$Version = '1.0.0',
  [string]$Workspace = (Join-Path $HOME '.rogeriosbf-core-skills'),
  [string]$ManifestPath,
  [string]$OutputDir,
  [switch]$UpdateSources
)

# Builds a Claude plugin archive (.zip) from selected manifest packages plus the
# repository's own skills in claude-plugin/skills. Upload the archive once on
# claude.ai so the skills sync to Claude Code on every machine, Cowork and the web.
# The archive is a personal build artifact: it is written to dist/ and never committed.

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
if (-not $ManifestPath) { $ManifestPath = Join-Path $repoRoot 'manifests/core-packages.json' }
if (-not $OutputDir) { $OutputDir = Join-Path $repoRoot 'dist' }
$ownSkillsRoot = Join-Path $repoRoot 'claude-plugin/skills'

if ($PluginName -notmatch '^[a-z0-9][a-z0-9-]*$') {
  throw "PluginName must use lowercase letters, digits, and hyphens."
}

function Invoke-Git {
  param([string[]]$GitArgs)
  & git @GitArgs
  if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed" }
}

function Sync-Package {
  param($Package, [string]$SourceRoot)
  $dest = Join-Path $SourceRoot $Package.id

  if (Test-Path (Join-Path $dest '.git')) {
    if ($UpdateSources) {
      Invoke-Git -GitArgs @('-C', $dest, 'fetch', '--depth', '1', 'origin')
      Invoke-Git -GitArgs @('-C', $dest, 'reset', '--hard', 'origin/HEAD')
    }
    return $dest
  }

  if (@($Package.sparse_paths).Count -gt 0) {
    Invoke-Git -GitArgs @('clone', '--depth', '1', '--filter=blob:none', '--sparse', $Package.repo, $dest)
    Invoke-Git -GitArgs (@('-C', $dest, 'sparse-checkout', 'set', '--no-cone') + @($Package.sparse_paths))
  } else {
    Invoke-Git -GitArgs @('clone', '--depth', '1', $Package.repo, $dest)
  }
  return $dest
}

function Get-SkillName {
  param([string]$SkillFile)
  $content = [System.IO.File]::ReadAllText($SkillFile, [System.Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
  if ($content -match '(?s)^\s*---\s*(.*?)\s*---' -and $Matches[1] -match '(?m)^\s*name:\s*(.+?)\s*$') {
    return $Matches[1].Trim().Trim('"').Trim("'")
  }
  return Split-Path -Leaf (Split-Path -Parent $SkillFile)
}

function Add-Skill {
  param([string]$SkillFile, [string]$StagingSkills, [hashtable]$Seen)
  $name = Get-SkillName -SkillFile $SkillFile
  if ($name -notmatch '^[a-z0-9][a-z0-9-]*$') { throw "Skill name '$name' in $SkillFile is not a valid directory name." }
  if ($Seen.ContainsKey($name)) { throw "Duplicate skill name '$name' ($SkillFile and $($Seen[$name]))." }
  $Seen[$name] = $SkillFile
  Copy-Item -LiteralPath (Split-Path -Parent $SkillFile) -Destination (Join-Path $StagingSkills $name) -Recurse -Force
  Remove-Item -LiteralPath (Join-Path $StagingSkills "$name/.git") -Recurse -Force -ErrorAction SilentlyContinue
  return $name
}

Write-Host "[ rogeriosbf CORE Skills ] - Claude plugin builder" -ForegroundColor Cyan

$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
$sourceRoot = Join-Path $Workspace 'sources'
New-Item -ItemType Directory -Force -Path $sourceRoot | Out-Null

$staging = Join-Path $OutputDir "$PluginName-staging"
if (Test-Path $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
$stagingSkills = Join-Path $staging 'skills'
New-Item -ItemType Directory -Force -Path $stagingSkills, (Join-Path $staging '.claude-plugin') | Out-Null

$seen = @{}
$sources = @()

foreach ($id in $IncludePackage) {
  $package = @($manifest.packages | Where-Object { $_.id -eq $id }) | Select-Object -First 1
  if (-not $package) { throw "Package '$id' not found in manifest." }
  if (-not $package.install_skills) { throw "Package '$id' is reference-only and has no skills to bundle." }
  if (@($package.platforms) -notcontains 'claude-code') { throw "Package '$id' does not declare claude-code support." }

  $packagePath = Sync-Package -Package $package -SourceRoot $sourceRoot
  $revision = ([string](& git -C $packagePath rev-parse HEAD)).Trim()

  $skillFiles = @()
  foreach ($root in @($package.skill_roots)) {
    $full = Join-Path $packagePath $root
    if (Test-Path $full) { $skillFiles += @(Get-ChildItem -Recurse -File -LiteralPath $full -Filter SKILL.md) }
  }
  if ($skillFiles.Count -eq 0) { throw "No SKILL.md found for package '$id' under its skill_roots." }

  foreach ($file in ($skillFiles | Sort-Object FullName -Unique)) {
    $name = Add-Skill -SkillFile $file.FullName -StagingSkills $stagingSkills -Seen $seen
    $sources += [pscustomobject]@{ skill=$name; package=$id; repo=$package.repo; revision=$revision; notes=$package.notes }
  }
}

if (Test-Path $ownSkillsRoot) {
  foreach ($file in (Get-ChildItem -Recurse -File -LiteralPath $ownSkillsRoot -Filter SKILL.md | Sort-Object FullName)) {
    $name = Add-Skill -SkillFile $file.FullName -StagingSkills $stagingSkills -Seen $seen
    $sources += [pscustomobject]@{ skill=$name; package='rogeriosbf-core-skills'; repo='https://github.com/sbfrogerio/rogeriosbf-core-skills.git'; revision=''; notes='Repository-owned skill (MIT).' }
  }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$pluginJson = [pscustomobject][ordered]@{
  name = $PluginName
  version = $Version
  description = "Curated web design and browser automation skills built by rogeriosbf CORE Skills: $((@($sources | Select-Object -ExpandProperty skill)) -join ', ')."
  author = [pscustomobject]@{ name = 'Rogerio Bezerra' }
  license = 'SEE SOURCES.md'
  repository = 'https://github.com/sbfrogerio/rogeriosbf-core-skills'
} | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $staging '.claude-plugin/plugin.json'), $pluginJson, $utf8NoBom)

$lines = @("# Sources", "", "Built $(Get-Date -Format 'yyyy-MM-dd') by scripts/build-claude-plugin.ps1. Upstream licenses apply to each skill; this bundle is for personal use.", "", "| Skill | Package | Upstream | Revision | Notes |", "|---|---|---|---|---|")
foreach ($s in $sources) {
  $lines += "| $($s.skill) | $($s.package) | $($s.repo) | $($s.revision) | $(([string]$s.notes) -replace '\|', '/') |"
}
[System.IO.File]::WriteAllText((Join-Path $staging 'SOURCES.md'), ($lines -join "`n") + "`n", $utf8NoBom)

$zipPath = Join-Path $OutputDir "$PluginName-$Version.zip"
if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path (Get-ChildItem -Force -LiteralPath $staging).FullName -DestinationPath $zipPath
Remove-Item -LiteralPath $staging -Recurse -Force

Write-Host "Bundled $($sources.Count) skill(s): $((@($sources | Select-Object -ExpandProperty skill)) -join ', ')" -ForegroundColor Green
Write-Host "Plugin archive: $zipPath" -ForegroundColor Green
Write-Host "Upload it on claude.ai (Customize > Plugins) to sync it to Claude Code, Cowork and the web." -ForegroundColor DarkGray
