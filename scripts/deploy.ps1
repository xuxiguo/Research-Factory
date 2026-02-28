# Deploy agents from repo to VS Code user-level prompts
# Usage: .\scripts\deploy.ps1 [-Agent <name>] [-DryRun]

param(
    [string]$Agent = "",
    [switch]$DryRun
)

$repoDir  = Join-Path $PSScriptRoot "..\agents"
$vsCodeDir = Join-Path $env:APPDATA "Code\User\prompts"

if (-not (Test-Path $vsCodeDir)) {
    New-Item -ItemType Directory -Path $vsCodeDir -Force | Out-Null
    Write-Host "Created VS Code prompts directory: $vsCodeDir" -ForegroundColor Yellow
}

$files = if ($Agent) {
    Get-ChildItem $repoDir -Filter "*$Agent*"
} else {
    Get-ChildItem $repoDir
}

$deployed = 0
$skipped  = 0

foreach ($f in $files) {
    $target = Join-Path $vsCodeDir $f.Name
    
    # Check if target exists and is identical
    if ((Test-Path $target) -and ((Get-FileHash $f.FullName).Hash -eq (Get-FileHash $target).Hash)) {
        $skipped++
        continue
    }
    
    if ($DryRun) {
        Write-Host "[DRY RUN] Would deploy: $($f.Name)" -ForegroundColor Cyan
    } else {
        Copy-Item $f.FullName -Destination $target -Force
        Write-Host "Deployed: $($f.Name)" -ForegroundColor Green
    }
    $deployed++
}

Write-Host ""
Write-Host "Summary: $deployed deployed, $skipped unchanged" -ForegroundColor White
if ($DryRun) { Write-Host "(Dry run — no files were actually copied)" -ForegroundColor Yellow }
