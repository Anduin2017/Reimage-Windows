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
InstallWinget    # Manual Approve
SignInAccount    # Manual Sign in

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

InstallVSCode    # Manual Sign in
InstallNextcloud # Manual Sign in. Slow
InstallDotnet
Install7Zip

WaitLinkForNextcloud

InstallGit       # Manual Sign in
InstallWindowsTerminal
InstallFdm
InstallVlc


Install-IfNotInstalled "Microsoft.Office"
Install-IfNotInstalled "Microsoft.PowerShell"
Install-IfNotInstalled "Microsoft.Edge"
Install-IfNotInstalled "Microsoft.NuGet"
Install-IfNotInstalled "Microsoft.EdgeWebView2Runtime"
Install-IfNotInstalled "Microsoft.AzureDataStudio"
Install-IfNotInstalled "Microsoft.OpenJDK.17"
Install-IfNotInstalled "Tencent.WeChat"
Install-IfNotInstalled "OBSProject.OBSStudio"
Install-IfNotInstalled "gerardog.gsudo"
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

RemoveUWP Microsoft.MSPaint
RemoveUWP Microsoft.Microsoft3DViewer
RemoveUWP Microsoft.ZuneMusic
RemoveUWP *549981C3F5F10*
RemoveUWP Microsoft.WindowsSoundRecorder
RemoveUWP Microsoft.PowerAutomateDesktop
RemoveUWP Microsoft.BingWeather
RemoveUWP Microsoft.BingNews
RemoveUWP king.com.CandyCrushSaga
RemoveUWP Microsoft.Messaging
RemoveUWP Microsoft.WindowsFeedbackHub
RemoveUWP Microsoft.MicrosoftOfficeHub
RemoveUWP Microsoft.MicrosoftSolitaireCollection
RemoveUWP 4DF9E0F8.Netflix
RemoveUWP Microsoft.GetHelp
RemoveUWP Microsoft.People
RemoveUWP Microsoft.YourPhone
RemoveUWP MicrosoftTeams
RemoveUWP Microsoft.Getstarted
RemoveUWP Microsoft.Microsoft3DViewer
RemoveUWP Microsoft.WindowsMaps
RemoveUWP Microsoft.MixedReality.Portal
RemoveUWP Microsoft.SkypeApp
RemoveUWP MicrosoftWindows.Client.WebExperience # Useless Widgets.

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

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 6  - Security   " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 7  - Updates    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

ResetStore
UpdateStoreApps
