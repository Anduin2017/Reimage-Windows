function Get-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    { Write-Output $true }      
    else
    { Write-Output $false }   
}

function Install-IfNotInstalled {
    param (
        [string]$package
    )

    if ("$(winget list --id $package)".Contains("--")) { 
        Write-Host "$package is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: $package..." -ForegroundColor Yellow
        winget install $package
    }
}

if (-not(Get-IsElevated)) { 
    throw "Please run this script as an administrator" 
}

if (-not $(Get-Command winget)) {
    Start-Process "https://github.com/microsoft/winget-cli/releases"
    return
}

Install-IfNotInstalled Microsoft.VisualStudioCode
Install-IfNotInstalled Microsoft.WindowsTerminal
Install-IfNotInstalled Microsoft.Teams
Install-IfNotInstalled Microsoft.Office
Install-IfNotInstalled Microsoft.OneDrive
Install-IfNotInstalled Microsoft.PowerShell
Install-IfNotInstalled Microsoft.dotnet
Install-IfNotInstalled Microsoft.Edge
Install-IfNotInstalled Microsoft.EdgeWebView2Runtime
# We shall not install Visual Studio. Since the user may not buy enterprise license.
# winget install Microsoft.VisualStudio.2019.Enterprise
Install-IfNotInstalled Microsoft.AzureDataStudio
Install-IfNotInstalled Tencent.WeChat
Install-IfNotInstalled SoftDeluxe.FreeDownloadManager
Install-IfNotInstalled VideoLAN.VLC
Install-IfNotInstalled OBSProject.OBSStudio
Install-IfNotInstalled Git.git
Install-IfNotInstalled OpenJS.NodeJS
Install-IfNotInstalled Postman.Postman
Install-IfNotInstalled 7zip.7zip

Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Yellow
Set-ExecutionPolicy remotesigned

Write-Host "Setting up .NET environment variables..." -ForegroundColor Yellow
$env:ASPNETCORE_ENVIRONMENT = 'Development'
$env:DOTNET_PRINT_TELEMETRY_MESSAGE = 'false'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'

Write-Host "Copying back SSH keys..." -ForegroundColor Yellow
$OneDrivePath = $(Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "OneDrive*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
mkdir $HOME\.ssh -Force
Copy-Item -Path "$HOME\$OneDrivePath\Storage\SSH\*" -Destination "$HOME\.ssh\"

Write-Host "Configuring git..." -ForegroundColor Yellow
git config --global user.email "anduin.xue@microsoft.com"
git config --global user.name "Anduin Xue"
git config --global core.autocrlf true

Write-Host "Copying back windows terminal configuration file..." -ForegroundColor Yellow
$wtConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item -Path "$HOME\$OneDrivePath\Storage\WT\settings.json" -Destination $wtConfigPath

Write-Host "Configuring windows terminal context menu..." -ForegroundColor Yellow
git clone https://github.com/lextm/windowsterminal-shell.git "$HOME\temp"
pwsh -command "$HOME\temp\install.ps1 mini"
Remove-Item $HOME\temp -Force -Recurse -Confirm:$false

Write-Host "Setting up .NET build environment..." -ForegroundColor Yellow
git clone https://github.com/AiursoftWeb/Infrastructures.git "$HOME/source/repos/AiursoftWeb/Infrastructures"
git clone https://github.com/AiursoftWeb/AiurVersionControl.git "$HOME/source/repos/AiursoftWeb/AiurVersionControl"
dotnet test "$HOME\source\repos\AiursoftWeb\Infrastructures\Aiursoft.Infrastructures.sln"

Write-Host "Enabling desktop icons..." -ForegroundColor Yellow
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"

# Clean
Write-Host "Cleaning desktop..." -ForegroundColor Yellow
Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false
Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false
Stop-Process -Name explorer -Force

if ("$(winget list --id Spotify.Spotify)".Contains("--")) { 
    Write-Host "Spotify is already installed!" -ForegroundColor Green
}
else {
    Write-Host "Attempting to download spotify installer..." -ForegroundColor Yellow
    $source = 'https://download.scdn.co/SpotifySetup.exe'
    Invoke-WebRequest -Uri $source -OutFile "$HOME\Desktop\spotify.exe"
}

# Upgrade all.
Write-Host "Checking for final upgrades..." -ForegroundColor Yellow
winget upgrade --all

# Do some cleaning.
& "C:\Program Files\Git\bin\bash.exe" .\clean.sh

# Reset network
cmd.exe /c .\reset-net.cmd

# Consider to reboot.
shutdown -r -t 60
