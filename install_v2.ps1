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

EnsureElevated   # Manual Approve
RenameComputer   # Manual Enter
$mail = GetUserEmail # Manual Enter
InstallWinget    # Manual Approve
SignInAccount    # Manual Sign in

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

InstallVSCode
InstallNextcloud # Manual Sign in. Slow

Write-Host "The next part is 100% automatic. You can have a cup of coffee!`n" -ForegroundColor DarkMagenta
InstallDotnet
Install7Zip
InstallVlc

WaitLinkForNextcloud
InstallGit -mail $mail # Requires Nextcloud for SSH keys
InstallWindowsTerminal # Requires Nextcloud for profile
InstallGSudo
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

# V2Ray, ChatGPT Next
Install-IfNotInstalled "Tencent.WeChat"
Install-IfNotInstalled "OBSProject.OBSStudio"
Install-IfNotInstalled "OpenJS.NodeJS"
Install-IfNotInstalled "Postman.Postman"
Install-IfNotInstalled "CPUID.CPU-Z"
Install-IfNotInstalled "CPUID.HWMonitor"
Install-IfNotInstalled "WinDirStat.WinDirStat"
Install-IfNotInstalled "FastCopy.FastCopy"
Install-IfNotInstalled "DBBrowserForSQLite.DBBrowserForSQLite"
Install-IfNotInstalled "CrystalDewWorld.CrystalDiskInfo"
Install-IfNotInstalled "CrystalDewWorld.CrystalDiskMark"
Install-IfNotInstalled "PassmarkSoftware.OSFMount"
Install-IfNotInstalled "Maxon.CinebenchR23"
Install-IfNotInstalled "MediaArea.MediaInfo.GUI"

Install-StoreApp -storeAppId "9wzdncrfjbh4" -wingetAppName "Microsoft Photos"
Install-StoreApp -storeAppId "9nblggh4qghw" -wingetAppName "Microsoft Sticky Notes"
Install-StoreApp -storeAppId "9MZ95KL8MR0L" -wingetAppName "Snip & Sketch"
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
Write-Host "        PART 3  - Terminal   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - SDK        " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

DownloadMyRepos

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ClearRecycleBin
SetupIME
SetupDesktop

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 6  - Security   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 7  - Updates    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ResetStore
UpdateStoreApps
ResetNet