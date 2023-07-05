Import-Module ".\actions\ManualDoNext.psm1" -Force -DisableNameChecking
Import-Module ".\actions\EnsureElevated.psm1" -Force -DisableNameChecking
Import-Module ".\actions\ShowOsInfo.psm1" -Force -DisableNameChecking
Import-Module ".\actions\RenameComputer.psm1" -Force -DisableNameChecking
Import-Module ".\actions\ResetStore.psm1" -Force -DisableNameChecking
Import-Module ".\actions\UpdateStoreApps.psm1" -Force -DisableNameChecking

Import-Module ".\components\DownloadMyRepos.psm1" -Force -DisableNameChecking
Import-Module ".\components\InstallWinget.psm1" -Force -DisableNameChecking

Clear-Host
Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 0  - Introduce  " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ManualDoNext
ShowOsInfo

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 1  - Prepare    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

EnsureElevated
$email = Read-Host -Prompt 'Input your email'
$name = Read-Host -Prompt 'Input your name'
RenameComputer
ResetStore
UpdateStoreApps
InstallWinget
DownloadMyRepos
