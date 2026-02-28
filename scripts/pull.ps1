# Pull agents from VS Code user-level prompts to repo
# Usage: .\scripts\pull.ps1 [-Agent <name>] [-DryRun]

param(
    [string]$Agent = "",
    [switch]$DryRun
)

$repoDir   = Join-Path $PSScriptRoot "..\agents"
$vsCodeDir = Join-Path $env:APPDATA "Code\User\prompts"

if (-not (Test-Path $vsCodeDir)) {
    Write-Host "VS Code prompts directory not found: $vsCodeDir" -ForegroundColor Red
    exit 1
}

$files = if ($Agent) {
    Get-ChildItem $vsCodeDir -Filter "*$Agent*"
} else {
    Get-ChildItem $vsCodeDir -Filter "*.agent.md"
    Get-ChildItem $vsCodeDir -Filter "*.py"
}

$pulled  = 0
$skipped = 0
$newFiles = 0

foreach ($f in $files) {
    $target = Join-Path $repoDir $f.Name
    
    if ((Test-Path $target) -and ((Get-FileHash $f.FullName).Hash -eq (Get-FileHash $target).Hash)) {
        $skipped++
        continue
    }
    
    $isNew = -not (Test-Path $target)
    
    if ($DryRun) {
        $action = if ($isNew) { "NEW" } else { "UPDATE" }
        Write-Host "[DRY RUN] Would pull [$action]: $($f.Name)" -ForegroundColor Cyan
    } else {
        Copy-Item $f.FullName -Destination $target -Force
        $action = if ($isNew) { "New" } else { "Updated" }
        Write-Host "${action}: $($f.Name)" -ForegroundColor Green
    }
    
    if ($isNew) { $newFiles++ } else { $pulled++ }
}

Write-Host ""
Write-Host "Summary: $pulled updated, $newFiles new, $skipped unchanged" -ForegroundColor White
if ($DryRun) { Write-Host "(Dry run — no files were actually copied)" -ForegroundColor Yellow }
