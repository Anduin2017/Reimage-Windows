Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallWindowsTerminal {
    Install-IfNotInstalled "Microsoft.WindowsTerminal"
    Write-Host "Linking back windows terminal configuration file..." -ForegroundColor Green
    $wtConfigPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $NextcloudConfigwt = "$HOME\Nextcloud\Storage\WT\settings.json"
    Get-Content -Path $NextcloudConfigwt -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path $wtConfigPath -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $wtConfigPath -Target $NextcloudConfigwt -Force
}

Export-ModuleMember -Function InstallWindowsTerminal
