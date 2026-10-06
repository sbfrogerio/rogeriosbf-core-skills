[CmdletBinding()]
param(
  [string]$ManifestPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')) 'manifests/core-packages.json')
)

$ErrorActionPreference = 'Stop'

function Fail {
  param([string]$Message)
  throw "Validation failed: $Message"
}

if (-not (Test-Path -LiteralPath $ManifestPath)) {
  Fail "Manifest not found: $ManifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json

if ($manifest.schema_version -ne 1) {
  Fail "Unsupported schema_version '$($manifest.schema_version)'."
}

$packages = @($manifest.packages)
if ($packages.Count -lt 1) {
  Fail 'Manifest contains no packages.'
}

$allowedPlatforms = @(
  'codex',
  'claude-code',
  'antigravity',
  'gemini',
  'cursor',
  'windsurf',
  'openclaw',
  'copilot',
  'opencode'
)

$requiredFields = @('id','name','type','repo','platforms','skill_roots','install_skills','reference_only')
$ids = @{}
$errors = New-Object System.Collections.Generic.List[string]

foreach ($package in $packages) {
  foreach ($field in $requiredFields) {
    if (-not ($package.PSObject.Properties.Name -contains $field)) {
      $errors.Add("$($package.id): missing field '$field'")
    }
  }

  if ([string]::IsNullOrWhiteSpace([string]$package.id)) {
    $errors.Add('package with empty id')
    continue
  }

  if ($package.id -notmatch '^[a-z0-9][a-z0-9-]*$') {
    $errors.Add("$($package.id): id must use lowercase letters, digits, and hyphens")
  }

  if ($ids.ContainsKey($package.id)) {
    $errors.Add("$($package.id): duplicate package id")
  } else {
    $ids[$package.id] = $true
  }

  if ($package.repo -notmatch '^https://github\.com/[^/]+/[^/]+\.git$') {
    $errors.Add("$($package.id): repo must be an HTTPS github.com clone URL ending in .git")
  }

  $platforms = @($package.platforms)
  if ($platforms.Count -eq 0) {
    $errors.Add("$($package.id): platforms must not be empty")
  }

  foreach ($platform in $platforms) {
    if ($allowedPlatforms -notcontains $platform) {
      $errors.Add("$($package.id): unsupported platform '$platform'")
    }
  }

  if ($package.install_skills -and $package.reference_only) {
    $errors.Add("$($package.id): install_skills=true conflicts with reference_only=true")
  }

  if ($package.install_skills -and @($package.skill_roots).Count -eq 0) {
    $errors.Add("$($package.id): installable package must declare at least one skill_root")
  }
}

if ($errors.Count -gt 0) {
  $errors | ForEach-Object { Write-Error $_ }
  exit 1
}

$codexPackages = @($packages | Where-Object { @($_.platforms) -contains 'codex' })
$codexInstallable = @($codexPackages | Where-Object { $_.install_skills -and -not $_.reference_only })
$referenceOnly = @($packages | Where-Object { $_.reference_only })

if ($codexInstallable.Count -lt 1) {
  Fail 'No installable Codex packages found.'
}

$scriptPaths = @(
  (Join-Path $PSScriptRoot 'install.ps1'),
  (Join-Path $PSScriptRoot 'uninstall.ps1'),
  (Join-Path $PSScriptRoot 'check-upstreams.ps1')
)

foreach ($scriptPath in $scriptPaths) {
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    Fail "Required script missing: $scriptPath"
  }

  $tokens = $null
  $parseErrors = $null
  [System.Management.Automation.Language.Parser]::ParseFile(
    $scriptPath,
    [ref]$tokens,
    [ref]$parseErrors
  ) | Out-Null

  if ($parseErrors) {
    $parseErrors | ForEach-Object { Write-Error $_ }
    exit 1
  }
}

Write-Host "Repository validation passed." -ForegroundColor Green
Write-Host "  Packages:            $($packages.Count)"
Write-Host "  Codex packages:      $($codexPackages.Count)"
Write-Host "  Codex installable:   $($codexInstallable.Count)"
Write-Host "  Reference-only:      $($referenceOnly.Count)"
