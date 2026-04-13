[CmdletBinding()]
param(
  [ValidateSet('codex','claude','antigravity','all')]
  [string[]]$Platform = @('all'),

  [string]$HomeRoot = $HOME,
  [switch]$RemoveCache,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Get-TargetRoots {
  param([string[]]$Platforms, [string]$Home)
  $roots = @()
  $expanded = if ($Platforms -contains 'all') { @('codex','claude','antigravity') } else { $Platforms }
  foreach ($platform in $expanded) {
    switch ($platform) {
      'codex' {
        $roots += [pscustomobject]@{ Platform='codex'; Path=(Join-Path $Home '.agents\skills') }
        $roots += [pscustomobject]@{ Platform='codex-legacy'; Path=(Join-Path $Home '.codex\skills') }
      }
      'claude' {
        $roots += [pscustomobject]@{ Platform='claude'; Path=(Join-Path $Home '.claude\skills') }
      }
      'antigravity' {
        $roots += [pscustomobject]@{ Platform='antigravity'; Path=(Join-Path $Home '.gemini\antigravity\skills') }
      }
    }
  }
  return $roots
}

$targets = Get-TargetRoots -Platforms $Platform -Home $HomeRoot
$removed = @()

foreach ($target in $targets) {
  if (-not (Test-Path $target.Path)) {
    Write-Host "Skipping $($target.Platform): $($target.Path) does not exist."
    continue
  }

  Get-ChildItem -Directory -LiteralPath $target.Path -ErrorAction SilentlyContinue |
    Where-Object {
      (Test-Path (Join-Path $_.FullName '_rogeriosbf_core_skill.json')) -or
      (Test-Path (Join-Path $_.FullName '_unlimited_core_skill.json'))
    } |
    ForEach-Object {
      if ($DryRun) {
        Write-Host "[DRY] Would remove: $($_.FullName)"
      } else {
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
        Write-Host "Removed: $($_.FullName)"
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
      Write-Host "[DRY] Would remove cache: $cache"
    } else {
      Remove-Item -LiteralPath $cache -Recurse -Force
      Write-Host "Removed cache: $cache"
    }
  }
}

Write-Host ""
Write-Host "Uninstall complete. Removed $($removed.Count) managed skill(s)."
if ($DryRun) { Write-Host "(Dry run — nothing was actually removed.)" }
]]>
