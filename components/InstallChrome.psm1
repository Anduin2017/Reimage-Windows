Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallChrome {
    Write-Host "Installing Microsoft Edge as your work browser...`n" -ForegroundColor Green
    Install-IfNotInstalled "Microsoft.Edge"

    Write-Host "Installing Google Chrome as your personal browser...`n" -ForegroundColor Green
    Install-IfNotInstalled "Google.Chrome"

    Write-Host "Installing Chromium as your private browser...`n" -ForegroundColor Green
    Install-IfNotInstalled "eloston.ungoogled-chromiumro"
}

Export-ModuleMember -Function InstallChrome
