# Check sync status between repo agents and VS Code user-level prompts
# Usage: .\scripts\sync-status.ps1

$repoDir   = Join-Path $PSScriptRoot "..\agents"
$vsCodeDir = Join-Path $env:APPDATA "Code\User\prompts"

Write-Host "=== Research Factory Sync Status ===" -ForegroundColor Cyan
Write-Host "Repo:    $repoDir"
Write-Host "VS Code: $vsCodeDir"
Write-Host ""

$repoFiles   = Get-ChildItem $repoDir   -Filter "*.agent.md" | Sort-Object Name
$vsCodeFiles = Get-ChildItem $vsCodeDir  -Filter "*.agent.md" | Sort-Object Name

$repoNames   = $repoFiles   | ForEach-Object { $_.Name }
$vsCodeNames = $vsCodeFiles | ForEach-Object { $_.Name }

# Files only in repo
$onlyRepo = $repoNames | Where-Object { $_ -notin $vsCodeNames }
# Files only in VS Code
$onlyVSCode = $vsCodeNames | Where-Object { $_ -notin $repoNames }
# Files in both — check hashes
$inBoth = $repoNames | Where-Object { $_ -in $vsCodeNames }

$synced   = @()
$modified = @()

foreach ($name in $inBoth) {
    $repoHash   = (Get-FileHash (Join-Path $repoDir   $name)).Hash
    $vsCodeHash = (Get-FileHash (Join-Path $vsCodeDir $name)).Hash
    
    if ($repoHash -eq $vsCodeHash) {
        $synced += $name
    } else {
        $modified += $name
    }
}

# Report
if ($synced.Count -gt 0) {
    Write-Host "In Sync ($($synced.Count)):" -ForegroundColor Green
    $synced | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGreen }
    Write-Host ""
}

if ($modified.Count -gt 0) {
    Write-Host "Modified (differs between repo and VS Code) ($($modified.Count)):" -ForegroundColor Yellow
    $modified | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    Write-Host ""
}

if ($onlyRepo.Count -gt 0) {
    Write-Host "Only in Repo ($($onlyRepo.Count)):" -ForegroundColor Magenta
    $onlyRepo | ForEach-Object { Write-Host "  $_" -ForegroundColor Magenta }
    Write-Host ""
}

if ($onlyVSCode.Count -gt 0) {
    Write-Host "Only in VS Code ($($onlyVSCode.Count)):" -ForegroundColor Red
    $onlyVSCode | ForEach-Object { Write-Host "  $_ — run pull.ps1 to capture" -ForegroundColor Red }
    Write-Host ""
}

# Also check helper scripts
$repoPy   = Get-ChildItem $repoDir   -Filter "*.py" -ErrorAction SilentlyContinue
$vsCodePy = Get-ChildItem $vsCodeDir -Filter "*.py" -ErrorAction SilentlyContinue

if ($repoPy -or $vsCodePy) {
    Write-Host "Helper Scripts:" -ForegroundColor Cyan
    $allPy = @()
    if ($repoPy)   { $allPy += $repoPy.Name }
    if ($vsCodePy) { $vsCodePy.Name | Where-Object { $_ -notin $allPy } | ForEach-Object { $allPy += $_ } }
    
    foreach ($py in $allPy) {
        $inR = Test-Path (Join-Path $repoDir $py)
        $inV = Test-Path (Join-Path $vsCodeDir $py)
        if ($inR -and $inV) {
            $match = (Get-FileHash (Join-Path $repoDir $py)).Hash -eq (Get-FileHash (Join-Path $vsCodeDir $py)).Hash
            $status = if ($match) { "Synced" } else { "Modified" }
            $color  = if ($match) { "Green" } else { "Yellow" }
        } elseif ($inR) {
            $status = "Only in repo"
            $color  = "Magenta"
        } else {
            $status = "Only in VS Code"
            $color  = "Red"
        }
        Write-Host "  $py — $status" -ForegroundColor $color
    }
}

Write-Host ""
Write-Host "Total: $($synced.Count) synced, $($modified.Count) modified, $($onlyRepo.Count) repo-only, $($onlyVSCode.Count) vscode-only" -ForegroundColor White
