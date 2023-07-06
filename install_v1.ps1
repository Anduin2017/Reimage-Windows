


function Set-WallPaper($Image) {
    Add-Type -TypeDefinition @" 
    using System; 
    using System.Runtime.InteropServices;

    public class Params
    { 
        [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
        public static extern int SystemParametersInfo (Int32 uAction, 
                                                       Int32 uParam, 
                                                       String lpvParam, 
                                                       Int32 fuWinIni);
    }
"@ 
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

$driveLetter = (Get-Location).Drive.Name

Write-Host "Installing NFS client..." -ForegroundColor Green
Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart



if (-not $(Get-Command Connect-AzureAD -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Nuget PowerShell Package Provider..." -ForegroundColor Green
    Install-PackageProvider -Name NuGet -Force
    Write-Host "Installing AzureAD PowerShell module..." -ForegroundColor Green
    Install-Module AzureAD -Force
}
else {
    Write-Host "Azure AD PowerShell Module is already installed!" -ForegroundColor Green
}

#iperf3
if ($true) {
    $apiUrl = "https://iperf.fr/iperf-download.php"
    $downloadAddress = (Invoke-WebRequest -Uri $apiUrl).Links |
    Where-Object { $_.href -like "download/windows/iperf-*-win64.zip" } |
    Select-Object -ExpandProperty href |
    Sort-Object { $_ -replace ".iperf-(.)-win64.zip", '$1' } -Descending |
    Select-Object -First 1
    
    $downloadUrl = "https://iperf.fr/$downloadAddress"
    $downloadPath = Join-Path -Path $env:TEMP -ChildPath "iperf3.zip"
    Qget $downloadUrl $downloadPath
    
    $installPath = Join-Path -Path $env:ProgramFiles -ChildPath "iperf3"
    Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
    $iperfPath = (Get-ChildItem -Path $installPath -Directory | Sort-Object -Property LastWriteTime -Descending)[0].FullName
    AddToPath -folder $iperfPath
    
    Remove-Item $downloadPath
}

# Android CLI
if ($true) {
    Write-Host "Downloading Android-Platform-Tools..." -ForegroundColor Green
    $toolsPath = "${env:ProgramFiles}\Android-Platform-Tools"
    $downloadUri = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    
    $downloadedTool = $env:USERPROFILE + "\platform-tools-latest-windows.zip"
    Remove-Item $downloadedTool -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "platform-tools-latest-windows.zip" --check-certificate=false
    
    & ${env:ProgramFiles}\7-Zip\7z.exe x $downloadedTool "-o$($toolsPath)" -y
    AddToPath -folder "$toolsPath\platform-tools"
    Remove-Item -Path $downloadedTool -Force
}

# FFmpeg
if ($true) {
    Write-Host "Downloading FFmpeg..." -ForegroundColor Green
    $ffmpegPath = "${env:ProgramFiles}\FFMPEG"
    $downloadUri = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
    
    $downloadedFfmpeg = $env:USERPROFILE + "\ffmpeg-git-full.7z"
    Remove-Item $downloadedFfmpeg -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "ffmpeg-git-full.7z" --check-certificate=false

    & ${env:ProgramFiles}\7-Zip\7z.exe x $downloadedFfmpeg "-o$($ffmpegPath)" -y
    $subPath = $(Get-ChildItem -Path $ffmpegPath | Where-Object { $_.Name -like "ffmpeg*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
    $subPath = Join-Path -Path $ffmpegPath -ChildPath $subPath
    $binPath = Join-Path -Path $subPath -ChildPath "bin"
    Remove-Item $ffmpegPath\*.exe
    Move-Item $binPath\*.exe $ffmpegPath

    Write-Host "Adding FFmpeg to PATH..." -ForegroundColor Green
    AddToPath -folder $ffmpegPath
    Remove-Item -Path $downloadedFfmpeg -Force
}

# # Kubernetes CLI
# if ($true) {
#     Write-Host "Downloading Kubernetes CLI..." -ForegroundColor Green
#     $toolsPath = "${env:ProgramFiles}\Kubernetes"
#     $downloadUri = "https://dl.k8s.io/release/v1.23.0/bin/windows/amd64/kubectl.exe"
    
#     $downloadedTool = $env:USERPROFILE + "\kubectl.exe"
#     Remove-Item $downloadedTool -ErrorAction SilentlyContinue
#     aria2c.exe $downloadUri -d $HOME -o "kubectl.exe" --check-certificate=false
    
#     New-Item -Type Directory -Path "${env:ProgramFiles}\Kubernetes" -ErrorAction SilentlyContinue
#     Move-Item $downloadedTool "$toolsPath\kubectl.exe" -Force
#     AddToPath -folder $toolsPath
# }

# wget
if ($true) {
    Write-Host "Downloading Wget..." -ForegroundColor Green
    $wgetPath = "${env:ProgramFiles}\wget"
    $downloadUri = "https://eternallybored.org/misc/wget/releases/wget-1.21.3-win64.zip"
    $downloadedWget = $env:USERPROFILE + "\wget-1.21.3-win64.zip"
    Remove-Item $downloadedWget -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "wget-1.21.3-win64.zip" --check-certificate=false
    
    & ${env:ProgramFiles}\7-Zip\7z.exe x $downloadedWget "-o$($wgetPath)" -y
    Write-Host "Adding wget to PATH..." -ForegroundColor Green
    AddToPath -folder $wgetPath
    Remove-Item -Path $downloadedWget -Force
}


if ($email.Contains('microsoft')) {
    Install-IfNotInstalled Microsoft.VisualStudio.2022.Enterprise
}
else {
    Install-IfNotInstalled Microsoft.VisualStudio.2022.Community
    winget remove Microsoft.OneDrive
}

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 3  - Terminal    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green


Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Green
Set-ExecutionPolicy remotesigned -Force

Write-Host "Enabling long path..." -ForegroundColor Green
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

Write-Host "Installing profile file..." -ForegroundColor Green
if (!(Test-Path $PROFILE)) {
    Write-Host "Creating PROFILE..." -ForegroundColor Yellow
    New-Item -Path $PROFILE -ItemType "file" -Force
}
$profileContent = (New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/PROFILE.ps1')
Set-Content $PROFILE $profileContent
. $PROFILE


Write-Host "Configuring double click ps1 file to run it..." -ForegroundColor Green
Set-ItemProperty "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\open\command" -Name "(default)" -Value "`"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`" -noLogo -ExecutionPolicy unrestricted -file `"%1`""



Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - SDK    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Setting up some node js global tools..." -ForegroundColor Green
npm install --global npm@latest
npm install --global node-static typescript @angular/cli yarn npm-check-updates redis-cli


Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

# Disabling Active Probing may increase performance. But on some machines may cause UWP unable to connect to Internet.
#Write-Host "Disabling rubbish Active Probing..." -ForegroundColor Green
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\" -Name EnableActiveProbing -Value 0 -Force
#Write-Host "Disabled Active Probing."

Write-Host "Clearing start up..." -ForegroundColor Green
$startUp = $env:USERPROFILE + "\Start Menu\Programs\StartUp\*"
Get-ChildItem $startUp
Remove-Item -Path $startUp
Get-ChildItem $startUp

Write-Host "Set home path hidden folders and files..." -ForegroundColor Green
Get-ChildItem -Path $HOME -Filter .* -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden }





Write-Host "Setting Power Policy to ultimate..." -ForegroundColor Green
powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /list



Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0
Write-Host "Monitor timeout set to 20."

Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor Green
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force

Write-Host "Enabling legacy photo viewer... because the Photos app in Windows 11 sucks!" -ForegroundColor Green
Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/restore-photo-viewer.reg" -OutFile ".\restore.reg"
regedit /s ".\restore.reg"
Remove-Item ".\restore.reg"


Write-Host "Setting Time zone..." -ForegroundColor Green
Set-TimeZone -Id "UTC"
Write-Host "Time zone set to UTC."

Write-Host "Syncing time..." -ForegroundColor Green
net stop w32time
net start w32time
w32tm /resync /force
w32tm /query /status



Write-Host "Pin repos to quick access..." -ForegroundColor Green
$load_com = new-object -com shell.application
$load_com.Namespace("$env:USERPROFILE\source\repos").Self.InvokeVerb("pintohome")
Write-Host "Repos folder are pinned to file explorer."

Write-Host "Exclude repos from Windows Defender..." -ForegroundColor Green
Add-MpPreference -ExclusionPath "$env:USERPROFILE\source\repos"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.nuget"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.dotnet"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.azuredatastudio"
Add-MpPreference -ExclusionPath "$env:APPDATA\npm"
Add-MpPreference -ExclusionPath "$NextcloudPath"



Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 6  - Security    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

$networkProfiles = Get-NetConnectionProfile
foreach ($networkProfile in $networkProfiles) {
    Write-Host "Setting network $($networkProfile.Name) to home network to enable more features..." -ForegroundColor Green
    Write-Host "This is dangerous because your roommates may detect your device is online." -ForegroundColor Yellow
    Set-NetConnectionProfile -Name $networkProfile.Name -NetworkCategory Private
}

Write-Host "Setting UAC..." -ForegroundColor Green
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "ConsentPromptBehaviorAdmin" -Value 5
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "PromptOnSecureDesktop" -Value 1

Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Upgrade all.
Write-Host "Checking for final app upgrades..." -ForegroundColor Green
winget upgrade --all --source winget

# Call the Update-PathVariable function
Write-Host "Cleaning path variable..." -ForegroundColor Green
Update-PathVariable -variableScope "Machine" -verbose

$(Invoke-WebRequest https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/test_env.sh).Content | bash

Write-Host "Press the [C] key to continue to steps which requires reboot."
$pressedKey = Read-Host
Write-Host "You pressed: $($pressedKey)"

if ($pressedKey -eq 'c') {
    Write-Host "Reseting WS..." -ForegroundColor Green
    WSReset.exe
    
    Write-Host "Scanning missing dlls..." -ForegroundColor Green
    sfc /scannow
    Write-Host y | chkdsk "$($driveLetter):" /f /r /x

    Write-Host "Checking for windows updates..." -ForegroundColor Green
    Install-Module -Name PSWindowsUpdate -Force
    Write-Host "Installing updates... (Computer will reboot in minutes...)" -ForegroundColor Green
    Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot

    cmd.exe /c "ipconfig /release"
    cmd.exe /c "ipconfig /flushdns"
    cmd.exe /c "ipconfig /renew"
    cmd.exe /c "netsh int ip reset"
    cmd.exe /c "netsh winsock reset"
    cmd.exe /c "route /f"
    cmd.exe /c "netcfg -d"
    cmd.exe /c "sc config FDResPub start=auto"
    cmd.exe /c "sc config fdPHost start=auto"
    cmd.exe /c "shutdown -r -t 10"
}

Do-Next


