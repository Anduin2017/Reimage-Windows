Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallNextcloud {
    if ("$(winget list -e --id "Nextcloud.NextcloudDesktop" --source winget)".Contains("--")) { 
        Write-Host "Nextcloud.NextcloudDesktop is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: Nextcloud.NextcloudDesktop..." -ForegroundColor Green
        winget install -e --id "Nextcloud.NextcloudDesktop" --source winget
        explorer.exe "C:\Program Files\Nextcloud\nextcloud.exe"
    }


    while (-not $(Get-Content -Path "$HOME\Nextcloud\Storage\SSH\id_rsa.pub" -ErrorAction SilentlyContinue)) {
        Write-Host "Nextcloud is still not ready!" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }

    Write-Host "Ensure Nextcloud files are readable..."
    Get-Content -Path "$HOME\Nextcloud\Storage\SSH\id_rsa.pub" -ErrorAction SilentlyContinue
    Get-Content -Path "$HOME\Nextcloud\Storage\SSH\id_rsa" -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function InstallNextcloud