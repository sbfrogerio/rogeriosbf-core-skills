[CmdletBinding()]
param(
  [string]$Owner = 'sbfrogerio',
  [string]$Repo = 'rogeriosbf-core-skills',
  [ValidateSet('public','private')]
  [string]$Visibility = 'public',
  [string]$Token = $env:GITHUB_TOKEN
)

$ErrorActionPreference = 'Stop'

if (-not $Token -and $env:GH_TOKEN) {
  $Token = $env:GH_TOKEN
}

function Invoke-GitChecked {
  param([string[]]$GitArgs)
  & git @GitArgs
  if ($LASTEXITCODE -ne 0) {
    throw "git $($GitArgs -join ' ') failed"
  }
}

$repoUrl = "https://github.com/$Owner/$Repo.git"

if (Get-Command gh -ErrorAction SilentlyContinue) {
  gh repo view "$Owner/$Repo" *> $null
  if ($LASTEXITCODE -ne 0) {
    gh repo create "$Owner/$Repo" "--$Visibility" --source . --remote origin --description "Replicable installer for Codex, Claude Code/Cowork and Antigravity skill packs."
    if ($LASTEXITCODE -ne 0) { throw 'gh repo create failed' }
  } else {
    git remote remove origin 2>$null
    git remote add origin $repoUrl
  }
  Invoke-GitChecked -GitArgs @('push','-u','origin','main')
  Write-Host "Published: https://github.com/$Owner/$Repo"
  return
}

if (-not $Token) {
  throw "No GitHub CLI found and no GITHUB_TOKEN/GH_TOKEN provided. Install gh or set a token with repo scope."
}

$headers = @{
  Authorization = "Bearer $Token"
  Accept = 'application/vnd.github+json'
  'X-GitHub-Api-Version' = '2022-11-28'
}

$exists = $false
try {
  Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$Owner/$Repo" -Headers $headers | Out-Null
  $exists = $true
} catch {
  if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
}

if (-not $exists) {
  $body = @{
    name = $Repo
    private = ($Visibility -eq 'private')
    description = 'Replicable installer for Codex, Claude Code/Cowork and Antigravity skill packs.'
    auto_init = $false
  } | ConvertTo-Json
  Invoke-RestMethod -Method Post -Uri 'https://api.github.com/user/repos' -Headers $headers -Body $body -ContentType 'application/json' | Out-Null
}

git remote remove origin 2>$null
git remote add origin $repoUrl

$encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("x-access-token:$Token"))
Invoke-GitChecked -GitArgs @('-c', "http.https://github.com/.extraheader=AUTHORIZATION: Basic $encoded", 'push', '-u', 'origin', 'main')

Write-Host "Published: https://github.com/$Owner/$Repo"
