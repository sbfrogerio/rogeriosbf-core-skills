[CmdletBinding()]
param(
  [ValidateSet('codex','claude','antigravity','all')]
  [string[]]$Platform = @('all'),

  [string]$HomeRoot = $HOME,
  [switch]$RemoveCache,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Write-Banner {
  Write-Host "===========================================================" -ForegroundColor Cyan
  Write-Host " [ rogeriosbf CORE Skills ] - Uninstaller" -ForegroundColor Cyan
  Write-Host "===========================================================" -ForegroundColor Cyan
  Write-Host ""
}

function Get-TargetRoots {
  param([string[]]$Platforms, [string]$HomeDir)
  $roots = @()
  $expanded = if ($Platforms -contains 'all') { @('codex','claude','antigravity') } else { $Platforms }
  foreach ($platform in $expanded) {
    switch ($platform) {
      'codex' {
        $roots += [pscustomobject]@{ Platform='codex'; Path=(Join-Path $HomeDir '.agents\skills') }
        $roots += [pscustomobject]@{ Platform='codex-legacy'; Path=(Join-Path $HomeDir '.codex\skills') }
      }
      'claude' {
        $roots += [pscustomobject]@{ Platform='claude'; Path=(Join-Path $HomeDir '.claude\skills') }
      }
      'antigravity' {
        $roots += [pscustomobject]@{ Platform='antigravity'; Path=(Join-Path $HomeDir '.gemini\antigravity\skills') }
      }
    }
  }
  return $roots
}

$targets = Get-TargetRoots -Platforms $Platform -HomeDir $HomeRoot
$removed = @()

foreach ($target in $targets) {
  if (-not (Test-Path $target.Path)) {
    Write-Host "[Skipped] $($target.Platform): $($target.Path) does not exist." -ForegroundColor DarkGray
    continue
  }

  Get-ChildItem -Directory -LiteralPath $target.Path -ErrorAction SilentlyContinue |
    Where-Object {
      (Test-Path (Join-Path $_.FullName '_rogeriosbf_core_skill.json')) -or
      (Test-Path (Join-Path $_.FullName '_unlimited_core_skill.json'))
    } |
    ForEach-Object {
      if ($DryRun) {
        Write-Host "[DRY RUN] Would remove: $($_.FullName)" -ForegroundColor Yellow
      } else {
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
        Write-Host "[Success] Removed: $($_.FullName)" -ForegroundColor Green
      }
      $removed += [pscustomobject]@{
        Platform = $target.Platform
        Path = $_.FullName
        Name = $_.Name
      }
    }
}

if ($RemoveCache) {
  $cache = Join-Path $HomeRoot '.rogeriosbf-core-skills'
  if (Test-Path $cache) {
    if ($DryRun) {
      Write-Host "[DRY RUN] Would remove cache: $cache" -ForegroundColor Yellow
    } else {
      Remove-Item -LiteralPath $cache -Recurse -Force
      Write-Host "[Success] Removed cache: $cache" -ForegroundColor Green
    }
  }
}

Write-Host ""
Write-Host "Uninstall complete. Removed $($removed.Count) managed skill(s)." -ForegroundColor Cyan
if ($DryRun) { Write-Host "(Dry run - nothing was actually removed.)" -ForegroundColor Yellow }
