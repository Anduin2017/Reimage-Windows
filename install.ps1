function Do-Next {
    Write-Host "What you can do next?`n`n" -ForegroundColor Yellow
    Write-Host " * Change your display scale" -ForegroundColor White
    Write-Host " * Turn off rubbish focus assistance" -ForegroundColor White
    Write-Host " * Teams turn on dark theme and start in background." -ForegroundColor White
    Write-Host " * Manually check store updates again." -ForegroundColor White
    Write-Host " * Manually sign in store personal account." -ForegroundColor White
    Write-Host " * Set Google as default search engine." -ForegroundColor White
    Write-Host " * Sign in To do." -ForegroundColor White
    Write-Host " * Sign in Sticky Notes." -ForegroundColor White
    Write-Host " * Sign in Mail UWP." -ForegroundColor White
    Write-Host " * Sign in browser extensions to use password manager." -ForegroundColor White
    Write-Host " * Turn on bitlocker" -ForegroundColor White
    Write-Host " * Sign in VSCode to turn on settings sync." -ForegroundColor White
    Write-Host " * Sign in Spotify and edit start up settings" -ForegroundColor White
    Write-Host " * Sign in WeChat" -ForegroundColor White
    Write-Host " * Sign in Visual Studio" -ForegroundColor White
    Write-Host " * Set Windows Terminal as default" -ForegroundColor White
    Write-Host " * Sign in the Xbox app" -ForegroundColor White
    Write-Host " * Activate Windows" -ForegroundColor White
}

function AddToPath {
    param (
        [string]$folder
    )

    Write-Host "Adding $folder to environment variables..." -ForegroundColor Yellow

    $currentEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine).Trim(";");
    $addedEnv = $currentEnv + ";$folder"
    $trimmedEnv = (($addedEnv.Split(';') | Select-Object -Unique) -join ";").Trim(";")
    [Environment]::SetEnvironmentVariable(
        "Path",
        $trimmedEnv,
        [EnvironmentVariableTarget]::Machine)

    #Write-Host "Reloading environment variables..." -ForegroundColor Green
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}


function Get-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    { Write-Output $true }      
    else
    { Write-Output $false }   
}

function Install-StoreApp {
    param (
        [string]$storeAppId,
        [string]$wingetAppName
    )

    if ("$(winget list --name $wingetAppName --exact --source msstore --accept-source-agreements)".Contains("--")) { 
        Write-Host "$wingetAppName is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to download $wingetAppName..." -ForegroundColor Green
        winget install --id $storeAppId.ToUpper() --name $wingetAppName  --exact --source msstore --accept-package-agreements --accept-source-agreements
    }
}

function Install-IfNotInstalled {
    param (
        [string]$package
    )

    if ("$(winget list -e --id $package --source winget)".Contains("--")) { 
        Write-Host "$package is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: $package..." -ForegroundColor Green
        winget install -e --id $package --source winget
    }
}

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

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 1  - Prepare    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

if (-not(Get-IsElevated)) { 
    throw "Please run this script as an administrator" 
}

if (-not $(Get-Command Connect-AzureAD -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Nuget PowerShell Package Provider..." -ForegroundColor Green
    Install-PackageProvider -Name NuGet -Force
    Write-Host "Installing AzureAD PowerShell module..." -ForegroundColor Green
    Install-Module AzureAD -Force
} else {
    Write-Host "Azure AD PowerShell Module is already installed!" -ForegroundColor Green
}
$aad = Connect-AzureAD
$email = $aad.Account.Id
$name = (Get-AzureADUser -ObjectId $email).DisplayName
$driveLetter = (Get-Location).Drive.Name
$computerName = Read-Host "Enter New Computer Name if you want to rename it: ($($env:COMPUTERNAME))"
if (-not ([string]::IsNullOrEmpty($computerName)))
{
    Write-Host "Renaming computer to $computerName..." -ForegroundColor Green
    cmd /c "bcdedit /set {current} description `"$computerName`""
    Rename-Computer -NewName $computerName
}

# Install Winget
if (-not $(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Installing WinGet..." -ForegroundColor Green
    Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
    while(-not $(Get-Command winget -ErrorAction SilentlyContinue))
    {
        Write-Host "Winget is still not found!" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

$screen = (Get-WmiObject -Class Win32_VideoController)
$screenX = $screen.CurrentHorizontalResolution
$screenY = $screen.CurrentVerticalResolution
Write-Host "Got screen: $screenX x $screenY" -ForegroundColor Green

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 2  - Install    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Do-Next

Write-Host "Triggering Store to upgrade all apps..." -ForegroundColor Green
$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
$wmiObj.UpdateScanMethod() | Format-Table -AutoSize

if ("$(winget list --id Microsoft.VisualStudioCode --source winget)".Contains("--")) { 
    Write-Host "Microsoft.VisualStudioCode is already installed!" -ForegroundColor Green
}
else {
    Write-Host "Attempting to download Microsoft VS Code..." -ForegroundColor Green
    winget install --exact --id Microsoft.VisualStudioCode --scope Machine --interactive --source winget
}

Install-IfNotInstalled "Microsoft.WindowsTerminal"
Install-IfNotInstalled "Microsoft.Teams"
Install-IfNotInstalled "Microsoft.Office"
Install-IfNotInstalled "Microsoft.OneDrive"
Install-IfNotInstalled "Microsoft.PowerShell"
Install-IfNotInstalled "Microsoft.dotnet"
Install-IfNotInstalled "Microsoft.Edge"
Install-IfNotInstalled "Microsoft.EdgeWebView2Runtime"
Install-IfNotInstalled "Microsoft.AzureCLI"
Install-IfNotInstalled "Microsoft.AzureDataStudio"
Install-IfNotInstalled "Microsoft.OpenJDK.17"
Install-IfNotInstalled "Tencent.WeChat"
Install-IfNotInstalled "Python.Python.3"
Install-IfNotInstalled "RubyInstallerTeam.Ruby"
Install-IfNotInstalled "GoLang.Go"
Install-IfNotInstalled "SoftDeluxe.FreeDownloadManager"
Install-IfNotInstalled "VideoLAN.VLC"
Install-IfNotInstalled "Telegram.TelegramDesktop"
Install-IfNotInstalled "OBSProject.OBSStudio"
Install-IfNotInstalled "Git.Git"
Install-IfNotInstalled "OpenJS.NodeJS"
Install-IfNotInstalled "Postman.Postman"
Install-IfNotInstalled "7zip.7zip"
Install-IfNotInstalled "CPUID.CPU-Z"
Install-IfNotInstalled "WinDirStat.WinDirStat"
Install-IfNotInstalled "FastCopy.FastCopy"
Install-IfNotInstalled "DBBrowserForSQLite.DBBrowserForSQLite"

Install-StoreApp -storeAppId "9NBLGGH5R558" -wingetAppName "Microsoft To Do"
Install-StoreApp -storeAppId "9MV0B5HZVK9Z" -wingetAppName "Xbox"
Install-StoreApp -storeAppId "9wzdncrfjbh4" -wingetAppName "Microsoft Photos"
Install-StoreApp -storeAppId "9nblggh4qghw" -wingetAppName "Microsoft Sticky Notes"
Install-StoreApp -storeAppId "9wzdncrfhvqm" -wingetAppName "Mail and Calendar"
Install-StoreApp -storeAppId "9mspc6mp8fm4" -wingetAppName "Microsoft Whiteboard"
Install-StoreApp -storeAppId "9wzdncrfhvjl" -wingetAppName "OneNote for Windows 10"

Write-Host "Configuring FDM..." -ForegroundColor Green
cmd /c "taskkill.exe /IM fdm.exe /F"
Remove-Item -Path "$env:LOCALAPPDATA\Softdeluxe" -Force -Recurse -ErrorAction SilentlyContinue
Start-Process "$env:ProgramFiles\Softdeluxe\Free Download Manager\fdm.exe"
Start-Sleep -Seconds 5
cmd /c "taskkill.exe /IM fdm.exe /F"
$fdmDbPath = "$env:LOCALAPPDATA\Softdeluxe\Free Download Manager\db.sqlite"
Invoke-WebRequest -Uri "https://github.com/Anduin2017/configuration-script-win/raw/main/db.sqlite" -OutFile "$fdmDbPath"

#aria2
if ($true)
{
    Write-Host "Installing aria2 as download tool..." -ForegroundColor Green
    $downloadAddress = "https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0-win-64bit-build1.zip"
    Invoke-WebRequest $downloadAddress -OutFile "$HOME\aria2.zip"
    $installPath = "${env:ProgramFiles}\aria2"
    & "${env:ProgramFiles}\7-Zip\7z.exe" x "$HOME\aria2.zip" "-o$($installPath)" -y
    $subPath = $(Get-ChildItem -Path $installPath | Where-Object { $_.Name -like "aria2-*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
    $subPath = Join-Path -Path $installPath -ChildPath $subPath
    Remove-Item $installPath\aria2c.exe -ErrorAction SilentlyContinue
    Move-Item $subPath\aria2c.exe $installPath
    AddToPath -folder $installPath
    Remove-Item -Path "$HOME\aria2.zip" -Force
}

# Spotify
if ("$(winget list -e --id "Spotify.Spotify" --source winget)".Contains("--")) { 
    Write-Host "Spotify is already installed!" -ForegroundColor Green
}
else {
    Write-Host "Attempting to install: $package..." -ForegroundColor Green
    aria2c.exe "https://download.scdn.co/SpotifySetup.exe" -d $HOME -o "spotify.exe" --check-certificate=false
    
    explorer "$HOME\spotify.exe"
}

# Chromium
if ($true) { 
    Write-Host "Installing Chromium as backup browser ..." -ForegroundColor Green
    $chromiumUrl = "https://download-chromium.appspot.com/dl/Win_x64?type=snapshots"
    $chromiumPath = "${env:ProgramFiles}\Chromium"
    
    $downloadedChromium = $env:USERPROFILE + "\chrome-win.zip"
    Remove-Item $downloadedChromium -ErrorAction SilentlyContinue
    aria2c.exe $chromiumUrl -d $HOME -o "chrome-win.zip" --check-certificate=false
    
    & "${env:ProgramFiles}\7-Zip\7z.exe" x $downloadedChromium "-o$($chromiumPath)" -y
    
    $shortCutPath = $env:USERPROFILE + "\Start Menu\Programs" + "\Chromium.lnk"
    Remove-Item -Path $shortCutPath -Force -ErrorAction SilentlyContinue
    $objShell = New-Object -ComObject ("WScript.Shell")
    $objShortCut = $objShell.CreateShortcut($shortCutPath)
    $objShortCut.TargetPath = "$chromiumPath\chrome-win\Chrome.exe"
    $objShortCut.Save()

    Remove-Item -Path $downloadedChromium -Force
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

# Kubernetes CLI
if ($true) {
    Write-Host "Downloading Kubernetes CLI..." -ForegroundColor Green
    $toolsPath = "${env:ProgramFiles}\Kubernetes"
    $downloadUri = "https://dl.k8s.io/release/v1.23.0/bin/windows/amd64/kubectl.exe"
    
    $downloadedTool = $env:USERPROFILE + "\kubectl.exe"
    Remove-Item $downloadedTool -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "kubectl.exe" --check-certificate=false
    
    New-Item -Type Directory -Path "${env:ProgramFiles}\Kubernetes" -ErrorAction SilentlyContinue
    Move-Item $downloadedTool "$toolsPath\kubectl.exe" -Force
    AddToPath -folder $toolsPath
}

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

if (-not $(Get-Command git-lfs)) {
    winget install "GitHub.GitLFS" --source winget
} else {
    Write-Host "Git LFS is already installed." -ForegroundColor Yellow
}

if ($email.Contains('microsoft')) {
    Install-IfNotInstalled Microsoft.VisualStudio.2022.Enterprise
} else {
    Install-IfNotInstalled Microsoft.VisualStudio.2022.Community
}

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 3  - Terminal    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

AddToPath -folder "C:\Program Files\Git\bin"

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
explorer "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
explorer "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

$OneDrivePath = $null
while ($null -eq $OneDrivePath -or -not $OneDrivePath.Contains("-")) {
    Write-Host "OneDrive is still not started!"
    # Wait till it finds my enterprise OneDrive folder.
    Start-Sleep -Seconds 10
    $OneDrivePath = $(Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "OneDrive*" } | Sort-Object Name -Descending | Select-Object -First 1).FullName
}
Get-ChildItem $OneDrivePath | Format-Table -AutoSize

Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Green
Set-ExecutionPolicy remotesigned

Write-Host "Installing profile file..." -ForegroundColor Green
if (!(Test-Path $PROFILE))
{
   Write-Host "Creating PROFILE..." -ForegroundColor Yellow
   New-Item -Path $PROFILE -ItemType "file" -Force
}
$profileContent = (New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/PROFILE.ps1')
Set-Content $PROFILE $profileContent
. $PROFILE

Write-Host "Linking back SSH keys..." -ForegroundColor Green
$oneDriveSshConfigPath = "$OneDrivePath\Storage\SSH\"
$localSshConfigPath = "$HOME\.ssh\"
$_ = Get-Content $oneDriveSshConfigPath\id_rsa.pub # Ensure file is available.
cmd /c "rmdir $localSshConfigPath /q"
cmd /c "mklink /d `"$localSshConfigPath`" `"$oneDriveSshConfigPath`""
Write-Host "Testing SSH features..." -ForegroundColor Green
Write-Host "yes" | ssh -o "StrictHostKeyChecking no" git@github.com

Write-Host "Linking back Videos..." -ForegroundColor Green
cmd /c "rmdir $env:USERPROFILE\Videos /q"
cmd /c "mklink /d `"$env:USERPROFILE\Videos`" `"$OneDrivePath\Digital\Pretty\Records\`""

Write-Host "Configuring git..." -ForegroundColor Green
Write-Host "Setting git email to $email" -ForegroundColor Yellow
Write-Host "Setting git name to $name" -ForegroundColor Yellow
git config --global user.email $email
git config --global user.name $name
git config --global core.autocrlf true

Write-Host "Linking back windows terminal configuration file..." -ForegroundColor Green
$wtConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$onedriveConfigwt = "$OneDrivePath\Storage\WT\settings.json"
$_ = Get-Content $onedriveConfigwt # Ensure file is available.
cmd /c "del `"$wtConfigPath`""
cmd /c "mklink `"$wtConfigPath`" `"$onedriveConfigwt`""

Write-Host "Configuring windows terminal context menu..." -ForegroundColor Green
git clone https://github.com/lextm/windowsterminal-shell.git "$HOME\temp"
pwsh -command "$HOME\temp\install.ps1 mini"
Remove-Item $HOME\temp -Force -Recurse -Confirm:$false

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - SDK    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Setting up some node js global tools..." -ForegroundColor Green
npm install --global npm@latest
npm install --global node-static typescript @angular/cli yarn npm-check-updates

Write-Host "Setting up .NET environment variables..." -ForegroundColor Green
[Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_PRINT_TELEMETRY_MESSAGE", "false", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")

if (-not (Test-Path -Path "$env:APPDATA\Nuget\Nuget.config") -or $null -eq (Select-String -Path "$env:APPDATA\Nuget\Nuget.config" -Pattern "nuget.org")) {
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
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/microsoft/artifacts-credprovider/master/helpers/installcredprovider.ps1'))
dotnet tool install --global dotnet-ef --interactive
dotnet tool update --global dotnet-ef --interactive

Write-Host "Building some .NET projects to ensure you can develop..." -ForegroundColor Green
git clone https://github.com/AiursoftWeb/Infrastructures.git "$HOME\source\repos\AiursoftWeb\Infrastructures"
git clone https://github.com/AiursoftWeb/AiurVersionControl.git "$HOME\source\repos\AiursoftWeb\AiurVersionControl"
git clone https://github.com/Anduin2017/Happiness-recorder.git "$HOME\source\repos\Anduin2017\Happiness-recorder"
dotnet publish "$HOME\source\repos\Anduin2017\Happiness-recorder\JAI.csproj" -c Release -r win-x64 -o "$OneDrivePath\Storage\Tools\JAL" --self-contained
git clone https://github.com/Anduin2017/Parser.git "$HOME\source\repos\Anduin2017\Parser"
$parserPath = "$OneDrivePath\Storage\Tools\Parser"
dotnet publish "$HOME\source\repos\Anduin2017\Parser\Parser.csproj" -c Release -r win-x64 -o $parserPath --self-contained
AddToPath -folder $parserPath

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Clearing recycle bin..." -ForegroundColor Green
Write-Host "Recycle bin cleared on $driveLetter..."
Clear-RecycleBin -DriveLetter $driveLetter -Force -Confirm

Write-Host "Disabling rubbish Active Probing..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\" -Name EnableActiveProbing -Value 0 -Force
Write-Host "Disabled Active Probing."

Write-Host "Clearing start up..." -ForegroundColor Green
$startUp = $env:USERPROFILE + "\Start Menu\Programs\StartUp\*"
Get-ChildItem $startUp
Remove-Item -Path $startUp
Get-ChildItem $startUp

Write-Host "Remove rubbish 3D objects..." -ForegroundColor Green
Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -ErrorAction SilentlyContinue
Write-Host "3D objects deleted."

Write-Host "Setting Power Policy to ultimate..." -ForegroundColor Green
powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /list

Write-Host "Enabling desktop icons..." -ForegroundColor Green
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"

$wallpaper = "$OneDrivePath\Digital\Wallpapers\Dark.jpg"
if (Test-Path $wallpaper) {
    Write-Host "Setting wallpaper to $wallpaper..." -ForegroundColor Green
    Set-WallPaper -Image $wallpaper
    Write-Host "Set to: " (Get-Item "$OneDrivePath\Digital\Wallpapers\Dark.jpg").Name
}

Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0
Write-Host "Monitor timeout set to 20."

Write-Host "Enabling Chinese input method..." -ForegroundColor Green
Start-Process powershell {
    $UserLanguageList = New-WinUserLanguageList -Language en-US
    $UserLanguageList.Add("zh-CN")
    Set-WinUserLanguageList $UserLanguageList -Force
    $UserLanguageList | Format-Table -AutoSize
}
Write-Host "Enabling Hardware-Accelerated GPU Scheduling" -ForegroundColor Green
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force

Write-Host "Enabling legacy photo viewer... because the Photos app in Windows 11 sucks!" -ForegroundColor Green
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Anduin2017/configuration-script-win/main/restore-photo-viewer.reg" -OutFile ".\restore.reg"
regedit /s ".\restore.reg"
Remove-Item ".\restore.reg"

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

Write-Host "Syncing time..." -ForegroundColor Green
net stop w32time
net start w32time
w32tm /resync /force
w32tm /query /status

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

Write-Host "Exclude repos from Windows Defender..." -ForegroundColor Green
Add-MpPreference -ExclusionPath "$env:USERPROFILE\source\repos"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.nuget"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.dotnet"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
Add-MpPreference -ExclusionPath "$env:USERPROFILE\.azuredatastudio"
Add-MpPreference -ExclusionPath "$env:APPDATA\npm"
Add-MpPreference -ExclusionPath "$OneDrivePath"

Write-Host "Enabling dark theme..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
Write-Host "Dark theme enabled."

Write-Host "Cleaning desktop..." -ForegroundColor Green
Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

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
winget upgrade --all --source winget

$(Invoke-WebRequest https://raw.githubusercontent.com/Anduin2017/configuration-script-win/main/test_env.sh).Content | bash

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

    cmd.exe /c "netsh winsock reset catalog"
    cmd.exe /c "netsh int ip reset reset.log"
    cmd.exe /c "ipconfig /flushdns"
    cmd.exe /c "ipconfig /registerdns"
    cmd.exe /c "route /f"
    cmd.exe /c "sc config FDResPub start=auto"
    cmd.exe /c "sc config fdPHost start=auto"
    cmd.exe /c "shutdown -r -t 70"
}

Do-Next
