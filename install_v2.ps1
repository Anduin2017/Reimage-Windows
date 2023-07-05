Clear-Host
Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 0  - Introduce  " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "This script is for Anduin to prepare an ready-to-use Windows environment. Based on a new clean Windows.`n`n" -ForegroundColor Yellow

Import-Module ".\actions\ManualDoNext.psm1" -Force -DisableNameChecking
Import-Module ".\actions\EnsureElevated.psm1" -Force -DisableNameChecking
Import-Module ".\components\DownloadMyRepos.psm1" -Force -DisableNameChecking

ManualDoNext

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 1  - Prepare    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green


EnsureElevated
DownloadMyRepos
