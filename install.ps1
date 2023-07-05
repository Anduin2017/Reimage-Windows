function Do-Next {
    Write-Host "What you can do next?`n`n" -ForegroundColor Yellow
    Write-Host " * Change your display scale" -ForegroundColor White
    Write-Host " * Sign in Nextcloud Desktop." -ForegroundColor White
    Write-Host " * Set Google as default search engine." -ForegroundColor White
    Write-Host " * Open office once." -ForegroundColor White
    Write-Host " * Sign in Mail UWP." -ForegroundColor White
    Write-Host " * Sign in VSCode and GitHub to turn on settings sync." -ForegroundColor White
    Write-Host " * Sign in WeChat and change shortcut" -ForegroundColor White
    Write-Host " * Sign in Youtube and Google" -ForegroundColor White
    Write-Host " * Set Windows Terminal as default" -ForegroundColor White
    Write-Host " * (Optional)Manually install latest NVIDIA drivers" -ForegroundColor White
    Write-Host " * Activate Windows" -ForegroundColor White
    Write-Host " * Sign in https://gitlab.aiursoft.cn" -ForegroundColor White
    Write-Host " * Install V2rayN" -ForegroundColor White
    Write-Host " * (Optional) Download and sign in ASUS Armoury Crate" -ForegroundColor White
    Write-Host " * (Optional) Sync NVIDIA Geforce experience settings and set shortcuts" -ForegroundColor White
    Write-Host " * (Optional) Sync Logitech shortcuts" -ForegroundColor White
    Write-Host " * (Optional) Run HDR Caliboration https://apps.microsoft.com/store/detail/windows-hdr-calibration/9N7F2SM5D1LR" -ForegroundColor White
}

function CloneReposToPath($repos, $destinationPath) {
    foreach ($repo in $repos) {
        $repoName = $repo.name
        $repoUrl = $repo.ssh_url_to_repo
        $repoPath = Join-Path $destinationPath $repoName

        if (!(Test-Path -Path $repoPath)) {
            git clone $repoUrl $repoPath
            Write-Host "Cloned $repoName to $repoPath"
        } else {
            Write-Host "$repoName already exists at $repoPath, skipping."
        }
    }
}

function Qget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$address,
        [string]$path = ""
    )

    if ($path -eq "") {
        $path = ".\$(Split-Path -Leaf $address)"
    }

    $aria2cArgs = "-c -s 128 -x 8 -k 4M -j 128 --split 128 `"$address`" -d `"$([System.IO.Path]::GetDirectoryName($path))`" -o `"$([System.IO.Path]::GetFileName($path))`" --check-certificate=false"
    Invoke-Expression "aria2c.exe $aria2cArgs"
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

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function RemoveUWP {
    param (
        [string]$name
    )

    Write-Host "Removing UWP $name..." -ForegroundColor Green
    Get-AppxPackage $name | Remove-AppxPackage
    Get-AppxPackage $name | Remove-AppxPackage -AllUsers
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

function Update-PathVariable {
    param (
        [string]$variableScope = "Machine",
        [switch]$verbose
    )

    # Get the current PATH environment variable
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", $variableScope)

    # Split the PATH string into an array of directories
    $directories = $currentPath -split ';'

    # Initialize an empty array to store updated directories
    $updatedDirectories = @()

    foreach ($directory in $directories) {
        # Check if the directory exists
        if (Test-Path -Path $directory -PathType Container) {
            # If the directory exists, add it to the updated directories array
            $updatedDirectories += $directory
        } elseif ($verbose) {
            # If the directory doesn't exist and verbose output is enabled, print the directory to be removed
            Write-Host "Removing non-existent directory from PATH: $directory"
        }
    }

    # Join the updated directories back into a single PATH string
    $newPath = $updatedDirectories -join ';'

    # Check if the new PATH value is different from the original value
    if ($newPath -eq $currentPath) {
        if ($verbose) {
            Write-Host "No changes needed to the $variableScope PATH variable."
        }
        return
    }

    try {
        # Set the new PATH environment variable
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $variableScope)

        if ($verbose) {
            # Print the updated PATH variable
            Write-Host "Updated $variableScope PATH: $($newPath)"
        }

        # Update the current session's PATH environment variable
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } catch {
        Write-Host "Error: Failed to update the $variableScope PATH variable. Please ensure you have the necessary permissions."
    }
}

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 1  - Prepare    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

if (-not(Get-IsElevated)) { 
    throw "Please run this script as an administrator" 
}

Write-Host "OS Info:" -ForegroundColor Green
Get-CimInstance Win32_OperatingSystem | Format-List Name, Version, InstallDate, OSArchitecture
(Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0\).ProcessorNameString

$email = Read-Host -Prompt 'Input your email'
$name = Read-Host -Prompt 'Input your name'

$driveLetter = (Get-Location).Drive.Name
$computerName = Read-Host "Enter New Computer Name if you want to rename it: ($($env:COMPUTERNAME))"
if (-not ([string]::IsNullOrEmpty($computerName))) {
    Write-Host "Renaming computer to $computerName..." -ForegroundColor Green
    cmd /c "bcdedit /set {current} description `"$computerName`""
    Rename-Computer -NewName $computerName
}

Write-Host "Reseting Store..." -ForegroundColor Green
wsreset.exe -i

# Install Winget
if (-not $(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Installing WinGet..." -ForegroundColor Green
    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1&mode=mini"

    Install-StoreApp -storeAppId "9NBLGGH4NNS1" -wingetAppName "App Installer"

    while (-not $(Get-Command winget -ErrorAction SilentlyContinue)) {
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

Install-IfNotInstalled "Nextcloud.NextcloudDesktop"
Install-IfNotInstalled "Microsoft.WindowsTerminal"
Install-IfNotInstalled "Microsoft.Office"
Install-IfNotInstalled "Microsoft.PowerShell"
Install-IfNotInstalled "Microsoft.DotNet.SDK.7"
Install-IfNotInstalled "Microsoft.Edge"
Install-IfNotInstalled "Microsoft.NuGet"
Install-IfNotInstalled "Microsoft.EdgeWebView2Runtime"
#Install-IfNotInstalled "Microsoft.AzureCLI"
#Install-IfNotInstalled "Microsoft.AzureDataStudio"
Install-IfNotInstalled "Microsoft.OpenJDK.17"
Install-IfNotInstalled "Tencent.WeChat"
#Install-IfNotInstalled "RubyInstallerTeam.Ruby.3.1"
#Install-IfNotInstalled "GoLang.Go.1.19"
Install-IfNotInstalled "SoftDeluxe.FreeDownloadManager"
Install-IfNotInstalled "VideoLAN.VLC"
#Install-IfNotInstalled "Telegram.TelegramDesktop"
Install-IfNotInstalled "OBSProject.OBSStudio"
Install-IfNotInstalled "Git.Git"
AddToPath "$env:ProgramFiles\Git\bin"
Install-IfNotInstalled "gerardog.gsudo"
Install-IfNotInstalled "OpenJS.NodeJS"
Install-IfNotInstalled "Postman.Postman"
Install-IfNotInstalled "7zip.7zip"
Install-IfNotInstalled "CPUID.CPU-Z"
Install-IfNotInstalled "WinDirStat.WinDirStat"
Install-IfNotInstalled "FastCopy.FastCopy"
Install-IfNotInstalled "DBBrowserForSQLite.DBBrowserForSQLite"
Install-IfNotInstalled "CrystalDewWorld.CrystalDiskInfo"
Install-IfNotInstalled "CrystalDewWorld.CrystalDiskMark"
Install-IfNotInstalled "PassmarkSoftware.OSFMount"
Install-IfNotInstalled "Maxon.CinebenchR23"
Install-IfNotInstalled "CPUID.HWMonitor"
Install-IfNotInstalled "MediaArea.MediaInfo.GUI"

Write-Host "Installing NFS client..." -ForegroundColor Green
Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart

Write-Host "Installing python tools..." -ForegroundColor Green
if (Get-Command -ErrorAction SilentlyContinue "python.exe") {
    Write-Host "Python is found! Removing Python..."
    winget uninstall Python.Python.3.10
    Write-Host "Removing existing python..." -ForegroundColor Green
    Remove-Item -Path "C:\Users\AnduinXue\AppData\Local\Microsoft\WindowsApps\python.exe" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:APPDATA\Python\" -Recurse -Force -ErrorAction SilentlyContinue
    $currentPath = [Environment]::GetEnvironmentVariable("PATH")
    $pathDirs = $currentPath -split ";"
    $pythonDirs = $pathDirs | Where-Object { $_ -like "*python*" }
    Write-Host "Removing existing path $pythonDirs..." -ForegroundColor Green
    $pythonDirs | ForEach-Object { $currentPath = $currentPath.Replace($_ + ";", "") }
    [Environment]::SetEnvironmentVariable("PATH", $currentPath, "Machine")
    $searchFolder = 'C:\Program Files'
    $folders = Get-ChildItem -Path $searchFolder -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*python*" }
    foreach ($folder in $folders) {
        Write-Host "Removing existing folder $folder..." -ForegroundColor Green
        Remove-Item $folder.FullName -Recurse -ErrorAction SilentlyContinue
    }
}

if (-not $(Get-Command Connect-AzureAD -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Nuget PowerShell Package Provider..." -ForegroundColor Green
    Install-PackageProvider -Name NuGet -Force
    Write-Host "Installing AzureAD PowerShell module..." -ForegroundColor Green
    Install-Module AzureAD -Force
}
else {
    Write-Host "Azure AD PowerShell Module is already installed!" -ForegroundColor Green
}

Install-StoreApp -storeAppId "9N0DX20HK701" -wingetAppName "Windows Terminal"
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

Write-Host "Configuring FDM..." -ForegroundColor Green
cmd /c "taskkill.exe /IM fdm.exe /F"
Remove-Item -Path "$env:LOCALAPPDATA\Softdeluxe" -Force -Recurse -ErrorAction SilentlyContinue
Start-Process "$env:ProgramFiles\Softdeluxe\Free Download Manager\fdm.exe"
Start-Sleep -Seconds 5
cmd /c "taskkill.exe /IM fdm.exe /F"
$fdmDbPath = "$env:LOCALAPPDATA\Softdeluxe\Free Download Manager\db.sqlite"
Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/db.sqlite?inline=false" -OutFile "$fdmDbPath"

#aria2
if ($true) {
    Write-Host "Installing aria2 as download tool..." -ForegroundColor Green

    $apiUrl = "https://api.github.com/repos/aria2/aria2/releases/latest"
    $downloadAddress = (Invoke-RestMethod -Uri $apiUrl).assets |
        Where-Object { $_.name -like "aria2-*-win-64bit-build1.zip" } |
        Select-Object -ExpandProperty browser_download_url
    Write-Host "Downloading aria2 from: $downloadAddress" -ForegroundColor Yellow

    $aria2ZipPath = Join-Path -Path $env:TEMP -ChildPath "aria2.zip"
    Invoke-WebRequest $downloadAddress -OutFile $aria2ZipPath

    $installPath = "${env:ProgramFiles}\aria2"
    New-Item -ItemType Directory -Force -Path $installPath | Out-Null

    Expand-Archive -LiteralPath $aria2ZipPath -DestinationPath $installPath -Force

    $subPath = Get-ChildItem -Path $installPath | Where-Object { $_.Name -like "aria2-*" } | Sort-Object Name -Descending | Select-Object -First 1
    $fullSubPath = Join-Path -Path $installPath -ChildPath $subPath.Name
    Move-Item -Path "$fullSubPath\*" -Destination $installPath -Force
    Remove-Item -Path $fullSubPath -Recurse -Force

    AddToPath -folder $installPath
    Remove-Item -Path $aria2ZipPath -Force
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

# Chromium
if ($true) {
    $downloadUrl = "https://download-chromium.appspot.com/dl/Win_x64?type=snapshots"
    $downloadPath = Join-Path -Path $env:TEMP -ChildPath "chromium.zip"
    Qget $downloadUrl $downloadPath

    $installPath = Join-Path -Path $env:ProgramFiles -ChildPath "Chromium"
    if (!(Test-Path -Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath | Out-Null
    }
    Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force

    $chromiumPath = (Get-ChildItem -Path $installPath -Directory | Sort-Object -Property LastWriteTime -Descending)[0].FullName

    $shortcutPath = Join-Path -Path ([Environment]::GetFolderPath("Programs")) -ChildPath "Chromium.lnk"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = Join-Path -Path $chromiumPath -ChildPath "chrome.exe"
    $Shortcut.IconLocation = Join-Path -Path $chromiumPath -ChildPath "chrome.exe"
    $Shortcut.Save()

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

if (-not $(Get-Command git-lfs)) {
    winget install "GitHub.GitLFS" --source winget
}
else {
    Write-Host "Git LFS is already installed." -ForegroundColor Yellow
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

AddToPath -folder "C:\Program Files\Git\bin"
AddToPath -folder "C:\Program Files\VideoLAN\VLC"

$NextcloudPath = $(Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "Nextcloud*" } | Sort-Object Name -Descending | Select-Object -First 1).FullName
while (-not $NextcloudPath) {
    Write-Host "Waiting for Nextcloud to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    $NextcloudPath = $(Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "Nextcloud*" } | Sort-Object Name -Descending | Select-Object -First 1).FullName
}

$nextcloudFiles = Get-ChildItem $NextcloudPath | Format-Table -AutoSize

while ($nextcloudFiles.Count -lt 5) {
    Write-Host "Waiting for Nextcloud to sync..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    $nextcloudFiles = Get-ChildItem $NextcloudPath | Format-Table -AutoSize
}

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

Write-Host "Linking back SSH keys..." -ForegroundColor Green
$NextcloudSshConfigPath = "$NextcloudPath\Storage\SSH\"
$localSshConfigPath = "$HOME\.ssh\"
$_ = Get-Content $NextcloudSshConfigPath\id_rsa.pub # Ensure file is available.
cmd /c "rmdir $localSshConfigPath /q"
cmd /c "mklink /d `"$localSshConfigPath`" `"$NextcloudSshConfigPath`""
Write-Host "Testing SSH features..." -ForegroundColor Green
Write-Host "yes" | ssh -o "StrictHostKeyChecking no" git@github.com

Write-Host "Configuring git..." -ForegroundColor Green
Write-Host "Setting git email to $email" -ForegroundColor Yellow
Write-Host "Setting git name to $name" -ForegroundColor Yellow
git config --global user.email $email
git config --global user.name $name
git config --global core.autocrlf true
git config --global core.longpaths true
git config --global --add safe.directory '*'

Write-Host "Linking back windows terminal configuration file..." -ForegroundColor Green
$wtConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$NextcloudConfigwt = "$NextcloudPath\Storage\WT\settings.json"
$_ = Get-Content $NextcloudConfigwt # Ensure file is available.
cmd /c "del `"$wtConfigPath`""
cmd /c "mklink `"$wtConfigPath`" `"$NextcloudConfigwt`""

Write-Host "Configuring double click ps1 file to run it..." -ForegroundColor Green
Set-ItemProperty "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\open\command" -Name "(default)" -Value "`"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`" -noLogo -ExecutionPolicy unrestricted -file `"%1`""

Write-Host "Configuring bash profile and bash rc..." -ForegroundColor Green
$bashProfile = "# generated by win.aiurs.co
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc"
Set-Content -Path "$env:HOMEPATH\.bash_profile" -Value $bashProfile
$bashRC = "# generated by win.aiurs.co
alias qget=`"aria2c.exe -c -s 16 -x 16 -k 1M -j 16`"
alias sudo=`"gsudo`"
alias redis-cli=`"rdcli`""
Set-Content -Path "$env:HOMEPATH\.bashrc" -Value $bashRC

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 4  - SDK    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Setting up some node js global tools..." -ForegroundColor Green
npm install --global npm@latest
npm install --global node-static typescript @angular/cli yarn npm-check-updates redis-cli

Write-Host "Setting up .NET environment variables..." -ForegroundColor Green
[Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_PRINT_TELEMETRY_MESSAGE", "false", "Machine")
[Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")

if (-not (Test-Path -Path "$env:APPDATA\Nuget\Nuget.config") -or $null -eq (Select-String -Path "$env:APPDATA\Nuget\Nuget.config" -Pattern "nuget.org")) {
    $config = "<?xml version=`"1.0`" encoding=`"utf-8`"?>`
    <configuration>`
      <packageSources>`
        <add key=`"aiursoft.cn`" value=`"https://nuget.aiursoft.cn/v3/index.json`" protocolVersion=`"3`" />`
        <add key=`"nuget.org`" value=`"https://api.nuget.org/v3/index.json`" protocolVersion=`"3`" />`
        <add key=`"Microsoft Visual Studio Offline Packages`" value=`"C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\`" />`
      </packageSources>`
      <config>`
        <add key=`"repositoryPath`" value=`"D:\CxCache`" />`
      </config>`
    </configuration>"
    Set-Content -Path "$env:APPDATA\Nuget\Nuget.config" -Value $config
}
else {
    Write-Host "Nuget config file already exists." -ForegroundColor Yellow
}
New-Item -Path "C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\" -ItemType directory -Force

Write-Host "Installing microsoft/artifacts-credprovider..." -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://git.aiursoft.cn/PublicVault/artifacts-credprovider/raw/branch/master/helpers/installcredprovider.ps1'))
dotnet tool install --global dotnet-ef --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool update --global dotnet-ef --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool install --global Anduin.Parser --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool update --global Anduin.Parser --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool install --global Aiursoft.NugetNinja --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool update --global Aiursoft.NugetNinja --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool install --global Aiursoft.Dotlang --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool update --global Aiursoft.Dotlang --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool install --global JetBrains.ReSharper.GlobalTools --interactive --add-source https://nuget.aiursoft.cn/v3/index.json
dotnet tool update --global JetBrains.ReSharper.GlobalTools --interactive --add-source https://nuget.aiursoft.cn/v3/index.json

Write-Host "Building some .NET projects to ensure you can develop..." -ForegroundColor Green
if ($true) {
    
    # 设置变量
    $gitlabBaseUrl = "https://gitlab.aiursoft.cn"
    $apiUrl = "$gitlabBaseUrl/api/v4"
    $groupName = "Aiursoft"
    $userName = "Anduin"

    $destinationPathAiursoft = "$HOME\source\repos\Aiursoft"
    $destinationPathAnduin = "$HOME\source\repos\Anduin"

    # 创建目标文件夹
    if (!(Test-Path -Path $destinationPathAiursoft)) {
        New-Item -ItemType Directory -Path $destinationPathAiursoft | Out-Null
    }
    if (!(Test-Path -Path $destinationPathAnduin)) {
        New-Item -ItemType Directory -Path $destinationPathAnduin | Out-Null
    }

    # 获取组织ID
    $groupUrl = "$apiUrl/groups?search=$groupName"
    $groupRequest = Invoke-RestMethod -Uri $groupUrl
    $groupId = $groupRequest[0].id

    # 获取用户ID
    $userUrl = "$apiUrl/users?username=$userName"
    $userRequest = Invoke-RestMethod -Uri $userUrl
    $userId = $userRequest[0].id

    # 获取仓库列表
    $repoUrlAiursoft = "$apiUrl/groups/$groupId/projects?simple=true&per_page=100"
    $repoUrlAnduin = "$apiUrl/users/$userId/projects?simple=true&per_page=100"

    $reposAiursoft = Invoke-RestMethod -Uri $repoUrlAiursoft
    $reposAnduin = Invoke-RestMethod -Uri $repoUrlAnduin

    # 克隆仓库
    CloneReposToPath $reposAiursoft $destinationPathAiursoft
    CloneReposToPath $reposAnduin $destinationPathAnduin
}
dotnet publish "$HOME\source\repos\Anduin\Happiness-recorder\JAI.csproj" -c Release -r win-x64 -o "$NextcloudPath\Storage\Tools\JAL" --self-contained

Write-Host "-----------------------------" -ForegroundColor Green
Write-Host "        PART 5  - Desktop    " -ForegroundColor Green
Write-Host "-----------------------------" -ForegroundColor Green

Write-Host "Clearing recycle bin..." -ForegroundColor Green
Write-Host "Recycle bin cleared on $driveLetter..."
Clear-RecycleBin -DriveLetter $driveLetter -Force -Confirm

# Disabling Active Probing may increase performance. But on some machines may cause UWP unable to connect to Internet.
#Write-Host "Disabling rubbish Active Probing..." -ForegroundColor Green
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet\" -Name EnableActiveProbing -Value 0 -Force
#Write-Host "Disabled Active Probing."
Write-Host "Disabling Alt+Tab swiching Edge tabs..." -ForegroundColor Green
New-Item         -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MultiTaskingAltTabFilter -Type DWORD -Value 3 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MultiTaskingAltTabFilter -Type DWORD -Value 3

Write-Host "Clearing start up..." -ForegroundColor Green
$startUp = $env:USERPROFILE + "\Start Menu\Programs\StartUp\*"
Get-ChildItem $startUp
Remove-Item -Path $startUp
Get-ChildItem $startUp

Write-Host "Set home path hidden folders and files..." -ForegroundColor Green
Get-ChildItem -Path $HOME -Filter .* -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden }

Write-Host "Avoid Edge showing sidebar..." -ForegroundColor Green
New-Item         -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name HubsSidebarEnabled -Type DWORD -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name HubsSidebarEnabled -Type DWORD -Value 0

Write-Host "Preventing rubbish folder grouping..." -ForegroundColor Green
(gci 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags' -s | ? PSChildName -eq '{885a186e-a440-4ada-812b-db871b942259}' ) | ri -Recurse

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

$wallpaper = "$NextcloudPath\Digital\Wallpapers\default.jpg"
if (Test-Path $wallpaper) {
    Write-Host "Setting wallpaper to $wallpaper..." -ForegroundColor Green
    Set-WallPaper -Image $wallpaper
    Write-Host "Set to: " (Get-Item "$NextcloudPath\Digital\Wallpapers\default.jpg").Name
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

Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor Green
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force

Write-Host "Disabling the Windows Ink Workspace..." -ForegroundColor Green
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /V PenWorkspaceButtonDesiredVisibility /T REG_DWORD /D 0 /F

Write-Host "Enabling legacy photo viewer... because the Photos app in Windows 11 sucks!" -ForegroundColor Green
Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/restore-photo-viewer.reg" -OutFile ".\restore.reg"
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
Set-TimeZone -Id "UTC"
Write-Host "Time zone set to UTC."

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
$load_com.Namespace("\\VAULT\").Self.InvokeVerb("pintohome")
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

