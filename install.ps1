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
        Write-Host "Attempting to install: $package..." -ForegroundColor Green
        winget install $package
    }
}

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 1  - Prepare    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

if (-not(Get-IsElevated)) { 
    throw "Please run this script as an administrator" 
}

if (-not $(Get-Command Connect-AzureAD)) {
    Install-PackageProvider -Name NuGet -Force
    Install-Module AzureAD -Force
} else {
    Write-Host "Azure AD PowerShell Module is already installed!" -ForegroundColor Green
}
$aad = Connect-AzureAD

$computerName = Read-Host "Enter New Computer Name if you want to rename it: ($($env:COMPUTERNAME))"
if (-not ([string]::IsNullOrEmpty($computerName)))
{
    Write-Host "Renaming computer to $computerName..." -ForegroundColor Green
    cmd /c "bcdedit /set {current} description `"$computerName`""
    Rename-Computer -NewName $computerName
}

if (-not $(Get-Command winget)) {
     Write-Host "Installing WinGet..." -ForegroundColor Green
    start "ms-appinstaller:?source=https://aka.ms/getwinget"
    if (-not $(Get-Command winget)) {
        start "C:\winget.msixbundle"
        while($true)
        {
            if (-not $(Get-Command winget))
            {
                Write-Host "Winget is still not found!" -ForegroundColor Yellow
                Start-Sleep -Seconds 5
            } 
            else
            {
                break
            }    
        }
    }
    Remove-Item -Path "C:\winget.msixbundle" -Force
}

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Triggering Store to upgrade all apps..." -ForegroundColor Green
$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
$result = $wmiObj.UpdateScanMethod()

#apps want to install
$appList = @(
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
    "OpenJS.NodeJS",
    "Postman.Postman",
    "7zip.7zip"
)

Write-Host "Starting to install apps..." -ForegroundColor Yellow
foreach ($app in $appList){
    Install-IfNotInstalled $app
}

Write-Host "Reloading environment variables..." -ForegroundColor Green
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
 
if (-not $env:Path.Contains("mpeg") -or -not $(Get-Command ffmpeg)) {
    Write-Host "Downloading FFmpeg..." -ForegroundColor Green
    $ffmpegPath = "C:\Program Files\FFMPEG"
    $downloadUri = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
    Invoke-WebRequest -Uri $downloadUri -OutFile "C:\ffmpeg.7z"
    & ${env:ProgramFiles}\7-Zip\7z.exe x "C:\ffmpeg.7z" "-o$($ffmpegPath)" -y
    $subPath = $(Get-ChildItem -Path $ffmpegPath | Where-Object { $_.Name -like "ffmpeg*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
    $subPath = Join-Path -Path $ffmpegPath -ChildPath $subPath
    $binPath = Join-Path -Path $subPath -ChildPath "bin"
    Write-Host "Adding FFmpeg to PATH..." -ForegroundColor Green
    [Environment]::SetEnvironmentVariable(
        "Path",
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$binPath",
        [EnvironmentVariableTarget]::Machine)
    Remove-Item -Path "C:\ffmpeg.7z" -Force
} else {
    Write-Host "FFmpeg is already installed." -ForegroundColor Yellow
}

if (-not $(Get-Command git-lfs)) {
    winget install "GitHub.GitLFS"
} else {
    Write-Host "Git LFS is already installed." -ForegroundColor Yellow
}

if ("$(winget list --id Tencent.WeChat)".Contains("--")) { 
    Write-Host "WeChat is already installed!" -ForegroundColor Green
}
else {
    Write-Host "Attempting to download WeChat..." -ForegroundColor Green
    winget install --exact --id Tencent.WeChat
}

if ("$(winget list --id Spotify)".Contains("--")) { 
    Write-Host "Spotify is already installed!" -ForegroundColor Green
    Set-Content -Path ".\upgrade-spotify.cmd" -value "winget upgrade Spotify.Spotify"
    explorer ".\upgrade-spotify.cmd"
    Start-Sleep -Seconds 10
    Remove-Item -Path ".\upgrade-spotify.cmd" -Force
}
else {
    Write-Host "Attempting to download spotify installer..." -ForegroundColor Green
    Set-Content -Path ".\install-spotify.cmd" -value "winget install Spotify.Spotify"
    explorer ".\install-spotify.cmd"
    Start-Sleep -Seconds 10
    Remove-Item -Path ".\install-spotify.cmd" -Force
}

if ("$(winget list --id Todos)".Contains("--")) { 
    Write-Host "Microsoft To do is already installed!" -ForegroundColor Green
}
else {
    Write-Host "Attempting to download Microsoft To do..." -ForegroundColor Green
    Start-Process "https://www.microsoft.com/en-US/p/microsoft-to-do-lists-tasks-reminders/9nblggh5r558"
}

if ("$(winget list --id Microsoft.VisualStudioCode)".Contains("--")) { 
    Write-Host "Microsoft.VisualStudioCode is already installed!" -ForegroundColor Green
}
else {
    Write-Host "Attempting to download Microsoft VS Code..." -ForegroundColor Green
    winget install --exact --id Microsoft.VisualStudioCode --scope Machine --interactive
}

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 3  - Terminal    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Enabling OneDrive silent sign in..." -ForegroundColor Green
$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'##Path to HKLM keys
$DiskSizeregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB'##Path to max disk size key
if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}
if(!(Test-Path $DiskSizeregistryPath)){New-Item -Path $DiskSizeregistryPath -Force}
Write-Host "Current AAD Tenant Id is $($aad.TenantId)"
New-ItemProperty -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable silent account configuration
New-ItemProperty -Path $DiskSizeregistryPath -Name $aad.TenantId -Value '102400' -PropertyType DWORD -Force | Out-Null ##Set max OneDrive threshold before prompting
Write-Host "Restarting OneDrive..." -ForegroundColor Yellow
taskkill.exe /IM OneDrive.exe /F
explorer "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
Start-Sleep -Seconds 10
$OneDrivePath = $(Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "OneDrive*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
Get-ChildItem $OneDrivePath

Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Green
Set-ExecutionPolicy remotesigned

Write-Host "Installing this script as Update-All..." -ForegroundColor Green
if (!(Test-Path $PROFILE))
{
   Write-Host "Creating PROFILE..." -ForegroundColor Yellow
   New-Item -Path $PROFILE -ItemType "file" -Force
}
Set-Content $PROFILE "function Update-All {
    iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/install.ps1'))
}"
. $PROFILE

Write-Host "Copying back SSH keys..." -ForegroundColor Green
mkdir $HOME\.ssh -ErrorAction SilentlyContinue
Copy-Item -Path "$HOME\$OneDrivePath\Storage\SSH\*" -Destination "$HOME\.ssh\"

Write-Host "Configuring git..." -ForegroundColor Green
$email = $aad.Account.Id
$name = (Get-AzureADUser -ObjectId $email).DisplayName
Write-Host "Setting git email to $email" -ForegroundColor Yellow
Write-Host "Setting git name to $name" -ForegroundColor Yellow
git config --global user.email $email
git config --global user.name $name
git config --global core.autocrlf true

Write-Host "Copying back windows terminal configuration file..." -ForegroundColor Green
$wtConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item -Path "$HOME\$OneDrivePath\Storage\WT\settings.json" -Destination $wtConfigPath

Write-Host "Configuring windows terminal context menu..." -ForegroundColor Green
git clone https://github.com/lextm/windowsterminal-shell.git "$HOME\temp"
pwsh -command "$HOME\temp\install.ps1 mini"
Remove-Item $HOME\temp -Force -Recurse -Confirm:$false

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - SDK    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Setting up some node js global tools..." -ForegroundColor Green
npm install --global npm@latest
npm install --global node-static typescript @angular/cli yarn

Write-Host "Setting up .NET environment variables..." -ForegroundColor Green
[Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_PRINT_TELEMETRY_MESSAGE", "false", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")

if (Test-Path -Path "$env:APPDATA\Nuget\Nuget.config") {
    $config = "<?xml version=`"1.0`" encoding=`"utf-8`"?>`
    <configuration>`
      <packageSources>`
        <add key=`"nuget.org`" value=`"https://api.nuget.org/v3/index.json`" protocolVersion=`"3`" />`
        <add key=`"Microsoft Visual Studio Offline Packages`" value=`"C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\`" />`
      </packageSources>`
      <config>`
        <add key=`"repositoryPath`" value=`"D:\CxCache`" />`
      </config>`
    </configuration>"
    Set-Content -Path "$env:APPDATA\Nuget\Nuget.config" -Value $config
} else {
    Write-Host "Nuget config file already exists." -ForegroundColor Yellow
}
New-Item -Path "C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\" -ItemType directory -Force

Write-Host "Installing Github.com/microsoft/artifacts-credprovider..." -ForegroundColor Green
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/microsoft/artifacts-credprovider/master/helpers/installcredprovider.ps1'))
dotnet tool install --global dotnet-ef --interactive
dotnet tool update --global dotnet-ef --interactive

Write-Host "Building some .NET projects to ensure you can develop..." -ForegroundColor Green
git clone https://github.com/AiursoftWeb/Infrastructures.git "$HOME\source\repos\AiursoftWeb\Infrastructures"
git clone https://github.com/AiursoftWeb/AiurVersionControl.git "$HOME\source\repos\AiursoftWeb\AiurVersionControl"
git clone https://github.com/Anduin2017/Happiness-recorder.git "$HOME\source\repos\Anduin2017\Happiness-recorder"
dotnet publish "$HOME\source\repos\Anduin2017\Happiness-recorder\JAI.csproj" -c Release -r win-x64 -o "$OneDrivePath\Storage\Tools\JAL"

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Enabling desktop icons..." -ForegroundColor Green
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"

Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

Write-Host "Enabling Chinese input method..." -ForegroundColor Green
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("zh-CN")
Set-WinUserLanguageList $LanguageList -Force

Write-Host "Removing Bluetooth icons..." -ForegroundColor Green
cmd.exe /c "reg add `"HKCU\Control Panel\Bluetooth`" /v `"Notification Area Icon`" /t REG_DWORD /d 0 /f"

Write-Host "Disabling apps auto start..." -ForegroundColor Green
cmd.exe /c "reg delete  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run /v Wechat /f"
cmd.exe /c "reg delete  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run /v `"Free Download Manager`" /f"

Write-Host "Applying file explorer settings..." -ForegroundColor Green
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v AutoCheckSelect /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"

Write-Host "Setting Time zone..." -ForegroundColor Green
Set-TimeZone -Name "China Standard Time"
Write-Host "Time zone set to China Standard Time."

Write-Host "Setting mouse speed..." -ForegroundColor Green
cmd.exe /c "reg add `"HKCU\Control Panel\Mouse`" /v MouseSensitivity /t REG_SZ /d 6 /f"
cmd.exe /c "reg add `"HKCU\Control Panel\Mouse`" /v MouseSpeed /t REG_SZ /d 0 /f"
cmd.exe /c "reg add `"HKCU\Control Panel\Mouse`" /v MouseThreshold1 /t REG_SZ /d 0 /f"
cmd.exe /c "reg add `"HKCU\Control Panel\Mouse`" /v MouseThreshold2 /t REG_SZ /d 0 /f"
Write-Host "Mouse speed changed. Will apply next reboot." -ForegroundColor Yellow

Write-Host "Pin repos to quick access..." -ForegroundColor Green
$load_com = new-object -com shell.application
$load_com.Namespace("$env:USERPROFILE\source\repos").Self.InvokeVerb("pintohome")
Write-Host "Repos folder are pinned to file explorer."

Write-Host "Enabling dark theme..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
Write-Host "Dark theme enabled."

Write-Host "Cleaning desktop..." -ForegroundColor Green
Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false
Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false

Write-Host "Resetting desktop..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Write-Host "Desktop cleaned."

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
winget upgrade --all

Write-Host "Checking for windows updates..." -ForegroundColor Green
Install-Module -Name PSWindowsUpdate -Force
Write-Host "Installing updates... (Computer will reboot in minutes...)" -ForegroundColor Green
Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot

cmd.exe /c "netsh winsock reset catalog"
cmd.exe /c "netsh int ip reset reset.log"
cmd.exe /c "ipconfig /flushdns"
cmd.exe /c "ipconfig /registerdns"
cmd.exe /c "route /f"
cmd.exe /c "sc config FDResPub start=auto"
cmd.exe /c "sc config fdPHost start=auto"
cmd.exe /c "shutdown -r -t 70"
