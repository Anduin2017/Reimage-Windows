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

    if ("$(winget list -e --id $package)".Contains("--")) { 
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

$computerName = Read-Host "Enter New Computer Name if you want to rename it: ($($env:COMPUTERNAME))"
if (-not ([string]::IsNullOrEmpty($computerName)))
{
    Write-Host "Renaming computer to $computerName..." -ForegroundColor Yellow
    Rename-Computer -NewName $computerName
}

if (-not $(Get-Command winget)) {
    Write-Host "Installing WinGet..." -ForegroundColor Yellow
    $releases_url = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri "$($releases_url)"
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith("msixbundle") } | Select -First 1
    Invoke-WebRequest -Uri $latestRelease.browser_download_url -OutFile "C:\winget.msixbundle"
    Add-AppxPackage -Path .\winget.msixbundle
    Write-Host "Reloading environment variables..." -ForegroundColor Yellow
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    if (-not $(Get-Command winget)) {
        start "C:\winget.msixbundle"
        while($true)
        {
            if (-not $(Get-Command winget))
            {
                Write-Host "Winget is still not found!" -ForegroundColor Yellow
                Start-Sleep -Milliseconds 500
            } 
            else
            {
                break
            }    
        }
    }
    Remove-Item -Path "C:\winget.msixbundle" -Force
}

#apps want to install
$appList = @(
    "Microsoft.VisualStudioCode",
    "Microsoft.WindowsTerminal",
    "Microsoft.Teams",
    "Microsoft.Office",
    "Microsoft.OneDrive",
    "Microsoft.PowerShell",
    "Microsoft.dotnet",
    "Microsoft.Edge",
    "Microsoft.EdgeWebView2Runtime",
    "Microsoft.AzureDataStudio",
    "Tencent.WeChat",
    "SoftDeluxe.FreeDownloadManager",
    "VideoLAN.VLC",
    "OBSProject.OBSStudio",
    "Git.Git",
    "GitHub.GitLFS",
    "OpenJS.NodeJS",
    "Postman.Postman",
    "7zip.7zip"
)

Write-Host "Starting to install apps..." -ForegroundColor Yellow
foreach ($app in $appList){
    Install-IfNotInstalled $app
}

Write-Host "Reloading environment variables..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
 
if (-not $env:Path.Contains("mpeg") -or -not $(Get-Command ffmpeg)) {
    Write-Host "Downloading FFmpeg..." -ForegroundColor Yellow
    $ffmpegPath = "C:\Program Files\FFMPEG"
    $downloadUri = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
    Invoke-WebRequest -Uri $downloadUri -OutFile "C:\ffmpeg.7z"
    & ${env:ProgramFiles}\7-Zip\7z.exe x "C:\ffmpeg.7z" "-o$($ffmpegPath)" -y
    $subPath = $(Get-ChildItem -Path $ffmpegPath | Where-Object { $_.Name -like "ffmpeg*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
    $subPath = Join-Path -Path $ffmpegPath -ChildPath $subPath
    $binPath = Join-Path -Path $subPath -ChildPath "bin"
    Write-Host "Adding FFmpeg to PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable(
        "Path",
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$binPath",
        [EnvironmentVariableTarget]::Machine)
    Remove-Item -Path "C:\ffmpeg.7z" -Force
} else {
    Write-Host "FFmpeg is already installed." -ForegroundColor Yellow
}

Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

Write-Host "Setting up some node js global tools..." -ForegroundColor Yellow
npm install --global npm@latest
npm install --global node-static typescript @angular/cli yarn

Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Yellow
Set-ExecutionPolicy remotesigned

Write-Host "Setting up .NET environment variables..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_PRINT_TELEMETRY_MESSAGE", "false", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")

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
dotnet tool install --global dotnet-ef
dotnet tool update --global dotnet-ef
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

# Write-Host "Enable Remote Desktop..." -ForegroundColor Yellow
# Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
# Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
# Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "Enabling Chinese input method..." -ForegroundColor Yellow
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("zh-CN")
Set-WinUserLanguageList $LanguageList -Force

Write-Host "Installing Github.com/microsoft/artifacts-credprovider..." -ForegroundColor Yellow
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/microsoft/artifacts-credprovider/master/helpers/installcredprovider.ps1'))

Write-Host "Removing Bluetooth icons..." -ForegroundColor Yellow
cmd.exe /c "reg add `"HKCU\Control Panel\Bluetooth`" /v `"Notification Area Icon`" /t REG_DWORD /d 0 /f"

Write-Host "Disabling apps auto start" -ForegroundColor Yellow
cmd.exe /c "reg delete  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run /v Wechat /f"
cmd.exe /c "reg delete  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run /v `"Free Download Manager`" /f"

# Clean desktop
Write-Host "Cleaning desktop..." -ForegroundColor Yellow
Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false
Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false
Stop-Process -Name explorer -Force

# Download spotify installer to desktop. Since spotify doesn't support to be installed from admin.
if ("$(winget list --id Spotify)".Contains("--")) { 
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
