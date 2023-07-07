
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

Write-Host "Installing profile file..." -ForegroundColor Green
if (!(Test-Path $PROFILE)) {
    Write-Host "Creating PROFILE..." -ForegroundColor Yellow
    New-Item -Path $PROFILE -ItemType "file" -Force
}
$profileContent = (New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/PROFILE.ps1')
Set-Content $PROFILE $profileContent
. $PROFILE

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green







Write-Host "Enabling legacy photo viewer... because the Photos app in Windows 11 sucks!" -ForegroundColor Green
Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/restore-photo-viewer.reg" -OutFile ".\restore.reg"
regedit /s ".\restore.reg"
Remove-Item ".\restore.reg"




Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 6  - Security    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green




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

}

Do-Next


