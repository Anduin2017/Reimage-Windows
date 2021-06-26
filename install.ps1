function Get-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    { Write-Output $true }      
    else
    { Write-Output $false }   
}

if (-not(Get-IsElevated)) { 
    throw "Please run this script as an administrator" 
}

if (-not $(Get-Command winget)) {
    Start-Process "https://github.com/microsoft/winget-cli/releases"
    return
}

winget install Microsoft.VisualStudioCode
winget install Microsoft.WindowsTerminal 
winget install Microsoft.Teams 
winget install Microsoft.Office
winget install Microsoft.OneDrive
winget install Microsoft.PowerShell
winget install Microsoft.dotnet
winget install Microsoft.Edge
winget install Microsoft.Edge.Update
winget install Microsoft.EdgeWebView2Runtime
# We shall not install Visual Studio. Since the user may not buy enterprise license.
# winget install Microsoft.VisualStudio.2019.Enterprise
winget install Microsoft.AzureDataStudio
winget install Microsoft.AzureStorageExplorer
winget install Tencent.WeChat
winget install FastCopy.FastCopy
winget install SoftDeluxe.FreeDownloadManager
winget install VideoLAN.VLC
winget install OBSProject.OBSStudio
winget install Git.git
winget install OpenJS.NodeJS
winget install Spotify.Spotify
winget install Postman.Postman

# Allow powershell script running. (Unsafe for some users.)
Set-ExecutionPolicy remotesigned

# Set .NET environment
$env:ASPNETCORE_ENVIRONMENT = 'Development'
$env:DOTNET_PRINT_TELEMETRY_MESSAGE = 'false'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'

# Copy back SSH keys. (Not available for all users. Copying back from my own OneDrive.)
Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "OneDrive*" }
$OneDrivePath = $(Get-ChildItem -Path $HOME | Where-Object { $_.Name -like "OneDrive*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
Copy-Item -Path "$HOME\$OneDrivePath\Storage\SSH\*" -Destination "$HOME\.ssh\"

# Copy back windows terminal configuration file. (Not available for all users. Copying back from my own OneDrive.)
$wtConfigPath = "C:\Users\xuef.FAREAST\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item -Path "$HOME\$OneDrivePath\Storage\WT\settings.json" -Destination $wtConfigPath

# Config windows terminal context.
git clone git@github.com:lextm/windowsterminal-shell.git "$HOME\temp"
pwsh -command "$HOME\temp\install.ps1 mini"
Remove-Item $HOME\temp -Force -Recurse -Confirm:$false

# Test dev environment source code.
Set-Location $HOME
mkdir source
mkdir source/repos
mkdir source/repos/AiursoftWeb
git clone git@github.com:AiursoftWeb/Infrastructures.git source/repos/AiursoftWeb
git clone git@github.com:AiursoftWeb/AiurVersionControl.git source/repos/AiursoftWeb
dotnet test $HOME/source/repos/AiursoftWeb/

# Show desktop icons
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {59031a47-3f72-44a7-89c5-5595fe6b30ee} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {645FF040-5081-101B-9F08-00AA002F954E} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {F02C1A0D-BE21-4350-88B0-7367FC96EF3C} /t REG_DWORD /d 0 /f"

# Clean desktop
Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false
Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false
Stop-Process -Name explorer -Force

# Finally, upgrade all.
winget upgrade --all

# Consider to reboot.
shutdown -r -t 60