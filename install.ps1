Get-ChildItem -Path $PSCommandPath -Recurse -Filter *.psm1 | ForEach-Object { Import-Module $_.FullName }
Clear-Host

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 0  - Introduce  " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ManualDoNext
ShowOsInfo

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 1  - Prepare    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

EnsureElevated   # Manual Approve
RenameComputer   # Manual Enter
$mail = GetUserEmail # Manual Enter
InstallWinget    # Manual Approve
SignInAccount    # Manual Sign in

InstallNextcloud # Manual Sign in. Slow
WaitLinkForNextcloud -path "$HOME\Nextcloud\Aiursoft\Box\costs.xlsx"

Write-Host "The following part is 100% automatic. You can have a cup of coffee!`n" -ForegroundColor DarkMagenta

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

InstallVSCode
InstallDotnet
Install7Zip
InstallVlc
InstallGSudo
InstallGit -mail $mail # Requires Nextcloud for SSH keys
InstallWindowsTerminal # Requires Nextcloud for profile
InstallPython
InstallAria2
InstallFdm
InstallChrome
InstallEdge
InstallJava
InstallOffice
InstallAzureDataStudio
InstallPwsh
InstallBlender
InstallWeChat
InstallWget
InstallV2rayN
InstallIPerf3
InstallFFmpeg
InstallAdb
InstallKubectl
InstallNodeJs
InstallNFSClient
InstallVS -mail $mail

if ($mail.Contains('microsoft')) {
    Write-Host "Welcome, Microsoft Employee!`n" -ForegroundColor DarkYellow
}
else {
    Write-Host "Remove MS trash!!!`n" -ForegroundColor DarkYellow
    RemoveOneDrive
    RemoveTeams
}

# V2Ray, ChatGPT Next
Install-IfNotInstalled "OBSProject.OBSStudio"
Install-IfNotInstalled "Postman.Postman"
Install-IfNotInstalled "CPUID.CPU-Z"
Install-IfNotInstalled "CPUID.HWMonitor"
Install-IfNotInstalled "WinDirStat.WinDirStat"
Install-IfNotInstalled "FastCopy.FastCopy"
Install-IfNotInstalled "DBBrowserForSQLite.DBBrowserForSQLite"
Install-IfNotInstalled "CrystalDewWorld.CrystalDiskInfo"
Install-IfNotInstalled "CrystalDewWorld.CrystalDiskMark"
Install-IfNotInstalled "PassmarkSoftware.OSFMount"

Install-StoreApp -storeAppId "9wzdncrfjbh4" -wingetAppName "Microsoft Photos"
Install-StoreApp -storeAppId "9nblggh4qghw" -wingetAppName "Microsoft Sticky Notes"
Install-StoreApp -storeAppId "9MZ95KL8MR0L" -wingetAppName "Snipping Tool"
Install-StoreApp -storeAppId "9WZDNCRFJ3PR" -wingetAppName "Windows Clock"
Install-StoreApp -storeAppId "9wzdncrfhvqm" -wingetAppName "Mail and Calendar"
Install-StoreApp -storeAppId "9WZDNCRFJBH4" -wingetAppName "Microsoft Photos"
Install-StoreApp -storeAppId "9N4D0MSMP0PT" -wingetAppName "VP9 Video Extensions"
Install-StoreApp -storeAppId "9N4D0MSMP0PT" -wingetAppName "AV1 Video Extension"

RemoveUwp Microsoft.MSPaint
RemoveUwp Microsoft.Microsoft3DViewer
RemoveUwp Microsoft.ZuneMusic
RemoveUwp *549981C3F5F10*
RemoveUwp Microsoft.WindowsSoundRecorder
RemoveUwp Microsoft.PowerAutomateDesktop
RemoveUwp Microsoft.BingWeather
RemoveUwp Microsoft.BingNews
RemoveUwp king.com.CandyCrushSaga
RemoveUwp Microsoft.Messaging
RemoveUwp Microsoft.WindowsFeedbackHub
RemoveUwp Microsoft.MicrosoftOfficeHub
RemoveUwp Microsoft.MicrosoftSolitaireCollection
RemoveUwp 4DF9E0F8.Netflix
RemoveUwp Microsoft.GetHelp
RemoveUwp Microsoft.People
RemoveUwp Microsoft.YourPhone
RemoveUwp MicrosoftTeams
RemoveUwp Microsoft.Getstarted
RemoveUwp Microsoft.Microsoft3DViewer
RemoveUwp Microsoft.WindowsMaps
RemoveUwp Microsoft.MixedReality.Portal
RemoveUwp Microsoft.SkypeApp
RemoveUwp MicrosoftWindows.Client.WebExperience # Useless Widgets.

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 3  - Code       " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ResetRepos
Update-PathVariable

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - Terminal   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

SetupPowershell

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

SetupGPU
SetupPower
ClearStartUp
ClearRecycleBin
SetupIME
SetTime
SetupDesktop

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 6  - Security   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

SetupNetwork
SetupRDP
SetupWindowsDefender
SetupUAC

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 7  - Updates    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

UpgradeAll
ResetStore
UpdateStoreApps
Set-CurrentProfileVersion
TestEnv
ManualDoNext

Write-Host "Most of the job finished. Do you want to do auto fix? Press Enter to disconnect now..." -ForegroundColor Yellow
Read-Host
FixDisk
ResetNet

Write-Host "Job finished! Pending reboot!" -ForegroundColor Green
Write-Host "Press Enter to reboot now..." -ForegroundColor Yellow
Read-Host

Restart-Computer -Force