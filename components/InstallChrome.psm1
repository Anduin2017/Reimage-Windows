Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallChrome {
    Write-Host "Installing Google Chrome as your personal browser...`n" -ForegroundColor Green
    Install-IfNotInstalled "Google.Chrome"

    Write-Host "Installing Chromium as your private browser...`n" -ForegroundColor Green
    Install-IfNotInstalled "eloston.ungoogled-chromium"

    Start-Sleep -Seconds 2
    Get-Process -Name Chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function InstallChrome
