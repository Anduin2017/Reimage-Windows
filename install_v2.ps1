Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.psm1 | ForEach-Object { Import-Module $_.FullName }

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


Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

InstallVSCode
InstallNextclooud




DownloadMyRepos
