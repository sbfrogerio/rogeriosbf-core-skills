[CmdletBinding()]
param(
  [ValidateSet('codex','claude','antigravity','all')]
  [string[]]$Platform = @('codex'),

  [string]$HomeRoot = $HOME,
  [string]$Workspace = (Join-Path $HOME '.unlimited-core-skills'),
  [string]$ManifestPath,

  [string[]]$IncludePackage = @(),
  [string[]]$ExcludePackage = @(),

  [switch]$InstallGsd,
  [switch]$MirrorCodexLegacy = $true,
  [switch]$DryRun,
  [switch]$UpdateSources
)

$ErrorActionPreference = 'Stop'

if (-not $ManifestPath) {
  $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
  $ManifestPath = Join-Path $repoRoot 'manifests\core-packages.json'
}

function Assert-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

function Get-SafePart {
  param([string]$Value, [int]$Max = 40)
  $safe = $Value.ToLowerInvariant() -replace '[^a-z0-9-]+','-'
  $safe = $safe.Trim('-')
  if ($safe.Length -gt $Max) { $safe = $safe.Substring(0, $Max).Trim('-') }
  if (-not $safe) { $safe = 'skill' }
  return $safe
}

function Get-ShortHash {
  param([string]$Value)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
  $hash = $sha.ComputeHash($bytes)
  return (($hash | Select-Object -First 4 | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-RelativePathSafe {
  param([string]$BasePath, [string]$FullPath)
  $base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
  $full = [System.IO.Path]::GetFullPath($FullPath)
  if ($full.StartsWith($base, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $full.Substring($base.Length)
  }
  return $FullPath
}

function Read-TextNoBom {
  param([string]$Path)
  return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
}

function Write-TextNoBom {
  param([string]$Path, [string]$Text)
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Get-SkillMetadata {
  param([string]$SkillFile, [string]$FallbackName)
  $content = Read-TextNoBom -Path $SkillFile
  $name = $FallbackName
  $description = 'Explicit skill imported by Unlimited CORE Skills.'

  if ($content -match '(?s)^\s*---\s*(.*?)\s*---') {
    $front = $Matches[1]
    if ($front -match '(?m)^\s*name:\s*(.+?)\s*$') {
      $name = $Matches[1].Trim().Trim('"').Trim("'")
    }
    if ($front -match '(?m)^\s*description:\s*(.+?)\s*$') {
      $description = $Matches[1].Trim().Trim('"').Trim("'")
    }
  }

  return [pscustomobject]@{
    Name = $name
    Description = $description
  }
}

function Normalize-SkillFile {
  param(
    [string]$SkillFile,
    [string]$NewName,
    [string]$Description
  )

  $content = Read-TextNoBom -Path $SkillFile
  $body = $content
  if ($content -match '(?s)^\s*---\s*(.*?)\s*---\s*(.*)$') {
    $body = $Matches[2]
  }

  $cleanDescription = ($Description -replace '[<>]', '')
  if (-not $cleanDescription) { $cleanDescription = 'Explicit skill imported by Unlimited CORE Skills.' }
  if ($cleanDescription.Length -gt 1024) { $cleanDescription = $cleanDescription.Substring(0, 1024) }
  $descriptionJson = $cleanDescription | ConvertTo-Json -Compress

  $normalized = "---`nname: $NewName`ndescription: $descriptionJson`n---`n`n$($body.TrimStart())"
  Write-TextNoBom -Path $SkillFile -Text $normalized
}

function Set-CodexExplicitPolicy {
  param([string]$SkillDir, [string]$DisplayName, [string]$ShortDescription)
  $agentsDir = Join-Path $SkillDir 'agents'
  $metadata = Join-Path $agentsDir 'openai.yaml'
  New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null

  $display = ($DisplayName -replace '"', '''')
  $desc = ($ShortDescription -replace '"', '''')
  if ($desc.Length -gt 180) { $desc = $desc.Substring(0, 180) }

  $content = @"
interface:
  display_name: "$display"
  short_description: "$desc"
  default_prompt: "Use this skill explicitly when needed."
policy:
  allow_implicit_invocation: false
"@
  Write-TextNoBom -Path $metadata -Text $content
}

function Invoke-Git {
  param([string[]]$GitArgs)
  & git @GitArgs
  if ($LASTEXITCODE -ne 0) {
    throw "git $($GitArgs -join ' ') failed"
  }
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

  if ($DryRun) {
    Write-Host "DRY clone $($Package.repo) -> $dest"
    return $dest
  }

  if (@($Package.sparse_paths).Count -gt 0) {
    Invoke-Git -GitArgs @('clone', '--depth', '1', '--filter=blob:none', '--sparse', $Package.repo, $dest)
    $sparseArgs = @('-C', $dest, 'sparse-checkout', 'set', '--no-cone') + @($Package.sparse_paths)
    Invoke-Git -GitArgs $sparseArgs
  } else {
    Invoke-Git -GitArgs @('clone', '--depth', '1', $Package.repo, $dest)
  }
  return $dest
}

function Get-SkillFilesForPackage {
  param($Package, [string]$PackagePath)
  $files = @()
  foreach ($root in @($Package.skill_roots)) {
    if (-not $root) { continue }
    $full = Join-Path $PackagePath $root
    if (Test-Path $full) {
      $files += @(Get-ChildItem -Recurse -File -LiteralPath $full -Filter SKILL.md -ErrorAction SilentlyContinue)
    }
  }
  if ($files.Count -eq 0 -and (Test-Path $PackagePath)) {
    $files = @(Get-ChildItem -Recurse -File -LiteralPath $PackagePath -Filter SKILL.md -ErrorAction SilentlyContinue)
  }
  return @($files | Sort-Object FullName -Unique)
}

function Get-TargetRoots {
  param([string[]]$Platforms)
  $roots = @()
  $expanded = if ($Platforms -contains 'all') { @('codex','claude','antigravity') } else { $Platforms }
  foreach ($platform in $expanded) {
    if ($platform -eq 'codex') {
      $roots += [pscustomobject]@{ Platform='codex'; Path=(Join-Path $HomeRoot '.agents\skills'); Codex=$true }
      if ($MirrorCodexLegacy) {
        $roots += [pscustomobject]@{ Platform='codex-legacy'; Path=(Join-Path $HomeRoot '.codex\skills'); Codex=$true }
      }
    } elseif ($platform -eq 'claude') {
      $roots += [pscustomobject]@{ Platform='claude'; Path=(Join-Path $HomeRoot '.claude\skills'); Codex=$false }
    } elseif ($platform -eq 'antigravity') {
      $roots += [pscustomobject]@{ Platform='antigravity'; Path=(Join-Path $HomeRoot '.gemini\antigravity\skills'); Codex=$false }
    }
  }
  return $roots
}

function Remove-PreviousManagedSkills {
  param([string]$TargetRoot)
  if (-not (Test-Path $TargetRoot)) { return }
  Get-ChildItem -Directory -LiteralPath $TargetRoot -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName '_unlimited_core_skill.json') } |
    ForEach-Object {
      if ($DryRun) { Write-Host "DRY remove $($_.FullName)" }
      else { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
    }
}

function Install-Skill {
  param(
    $Package,
    [string]$SkillFile,
    [string]$PackagePath,
    $Target
  )

  $sourceDir = Split-Path -Parent $SkillFile
  $relative = Get-RelativePathSafe -BasePath $PackagePath -FullPath $SkillFile
  $meta = Get-SkillMetadata -SkillFile $SkillFile -FallbackName (Split-Path -Leaf $sourceDir)
  $hash = Get-ShortHash "$($Package.id)|$relative|$($Target.Platform)"

  $packagePart = Get-SafePart $Package.id 24
  $nameMax = 64 - 14 - $packagePart.Length
  if ($nameMax -lt 12) { $nameMax = 12 }
  $installName = "ucs-{0}-{1}-{2}" -f $packagePart, (Get-SafePart $meta.Name $nameMax), $hash

  $dest = Join-Path $Target.Path $installName
  if ($DryRun) {
    Write-Host "DRY install $relative -> $dest"
    return $installName
  }

  Copy-Item -LiteralPath $sourceDir -Destination $dest -Recurse -Force
  Normalize-SkillFile -SkillFile (Join-Path $dest 'SKILL.md') -NewName $installName -Description $meta.Description

  if ($Target.Codex) {
    Set-CodexExplicitPolicy -SkillDir $dest -DisplayName $meta.Name -ShortDescription $meta.Description
  }

  $marker = [pscustomobject][ordered]@{
    managed_by = 'unlimited-core-skills'
    package_id = $Package.id
    package_name = $Package.name
    source_repo = $Package.repo
    source_skill = $relative
    installed_skill_name = $installName
    platform = $Target.Platform
    installed_at = (Get-Date).ToString('o')
  } | ConvertTo-Json -Depth 5
  Write-TextNoBom -Path (Join-Path $dest '_unlimited_core_skill.json') -Text $marker

  return $installName
}

function Install-GsdPackage {
  param([string]$GsdPath, [string[]]$Platforms)
  if (-not $InstallGsd) { return }
  if (-not (Test-Path (Join-Path $GsdPath 'bin\install.js'))) {
    Write-Warning "GSD package was not cloned; skipping GSD installer."
    return
  }
  Assert-Command node

  $expanded = if ($Platforms -contains 'all') { @('codex','claude','antigravity') } else { $Platforms }
  foreach ($platform in $expanded) {
    $args = @((Join-Path $GsdPath 'bin\install.js'), "--$platform", '--global')
    if ($DryRun) { Write-Host "DRY node $($args -join ' ')" }
    else {
      & node @args
      if ($LASTEXITCODE -ne 0) { throw "Get Shit Done installer failed for $platform" }
    }
  }
}

Assert-Command git
if (-not (Test-Path $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
$sourceRoot = Join-Path $Workspace 'sources'
$reportRoot = Join-Path $Workspace 'reports'

if (-not $DryRun) {
  New-Item -ItemType Directory -Force -Path $sourceRoot | Out-Null
  New-Item -ItemType Directory -Force -Path $reportRoot | Out-Null
}

$targets = Get-TargetRoots -Platforms $Platform
foreach ($target in $targets) {
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $target.Path | Out-Null }
  Remove-PreviousManagedSkills -TargetRoot $target.Path
}

$selectedPackages = @($manifest.packages | Where-Object {
  (@($IncludePackage).Count -eq 0 -or $IncludePackage -contains $_.id) -and
  (-not ($ExcludePackage -contains $_.id))
})

$installed = @()
$skipped = @()
$gsdPath = $null

foreach ($package in $selectedPackages) {
  if ($package.id -eq 'get-shit-done') {
    $gsdPath = Sync-Package -Package $package -SourceRoot $sourceRoot
    $skipped += [pscustomobject]@{ package_id=$package.id; reason='handled-by-optional-installer' }
    continue
  }

  $packagePath = Sync-Package -Package $package -SourceRoot $sourceRoot

  if (-not $package.install_skills) {
    $skipped += [pscustomobject]@{ package_id=$package.id; reason='reference-only' }
    continue
  }

  $skillFiles = Get-SkillFilesForPackage -Package $package -PackagePath $packagePath
  foreach ($skillFile in $skillFiles) {
    foreach ($target in $targets) {
      $name = Install-Skill -Package $package -SkillFile $skillFile.FullName -PackagePath $packagePath -Target $target
      $installed += [pscustomobject]@{
        package_id = $package.id
        platform = $target.Platform
        skill_name = $name
      }
    }
  }
}

if ($gsdPath) {
  Install-GsdPackage -GsdPath $gsdPath -Platforms $Platform
}

$summary = [pscustomobject][ordered]@{
  generated_at = (Get-Date).ToString('o')
  workspace = $Workspace
  platforms = $Platform
  targets = $targets
  installed_count = $installed.Count
  installed_unique_count = @($installed | Select-Object -ExpandProperty skill_name -Unique).Count
  skipped = $skipped
  packages = @($installed | Group-Object package_id | ForEach-Object {
    [pscustomobject]@{ package_id=$_.Name; installed=$_.Count }
  } | Sort-Object package_id)
}

if (-not $DryRun) {
  $summaryPath = Join-Path $reportRoot 'install-summary.json'
  $summaryJson = $summary | ConvertTo-Json -Depth 8
  Write-TextNoBom -Path $summaryPath -Text $summaryJson
  Write-Host "Wrote $summaryPath"
}

$summary | ConvertTo-Json -Depth 8
