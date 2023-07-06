Import-Module "..\tools\Install-StoreApp.psm1"
Import-Module "..\actions\WaitLinkForNextcloud.psm1"

function InstallWindowsTerminal {
    Install-StoreApp -storeAppId "9N0DX20HK701" -wingetAppName "Windows Terminal"

    WaitLinkForNextcloud -path "$HOME\Nextcloud\Storage\WT\settings.json"
    Write-Host "Linking back windows terminal configuration file..." -ForegroundColor Green

    $wtConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $NextcloudConfigwt = "$HOME\Nextcloud\Storage\WT\settings.json"
    Get-Content -Path $NextcloudConfigwt -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path $wtConfigPath -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $wtConfigPath -Target $NextcloudConfigwt -Force -ErrorAction SilentlyContinue | Out-Null
    
    Start-Sleep -Seconds 1
    explorer $(where.exe wt.exe)
}

Export-ModuleMember -Function InstallWindowsTerminal
