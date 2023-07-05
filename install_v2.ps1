Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.psm1 | ForEach-Object { Import-Module $_.FullName }

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
InstallWinget
SignInAccount

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

InstallVSCode
InstallNextcloud
InstallGit
InstallWindowsTerminal

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 3  - Terminal   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - SDK    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

DownloadMyRepos

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 6  - Security   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 7  - Updates    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ResetStore
UpdateStoreApps
