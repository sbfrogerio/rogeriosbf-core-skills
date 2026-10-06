[CmdletBinding()]
param(
  [string]$ManifestPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')) 'manifests/core-packages.json')
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw 'git is required to check upstream repositories.'
}

if (-not (Test-Path -LiteralPath $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
$failures = New-Object System.Collections.Generic.List[string]

foreach ($package in @($manifest.packages)) {
  Write-Host "Checking $($package.id) -> $($package.repo)"
  & git ls-remote --exit-code $package.repo HEAD 2>$null | Out-Null

  if ($LASTEXITCODE -ne 0) {
    $failures.Add("$($package.id): $($package.repo)")
  }
}

if ($failures.Count -gt 0) {
  Write-Error "Unreachable upstream repositories:"
  $failures | ForEach-Object { Write-Error "  $_" }
  exit 1
}

Write-Host "All $(@($manifest.packages).Count) upstream repositories are reachable." -ForegroundColor Green
