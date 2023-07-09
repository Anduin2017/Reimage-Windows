Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallNextcloud {
    if ("$(winget list -e --id "Nextcloud.NextcloudDesktop" --source winget)".Contains("--")) { 
        Write-Host "Nextcloud.NextcloudDesktop is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: Nextcloud.NextcloudDesktop..." -ForegroundColor Green
        winget install -e --id "Nextcloud.NextcloudDesktop" --source winget
        explorer.exe "C:\Program Files\Nextcloud\nextcloud.exe"
    }
}

Export-ModuleMember -Function InstallNextcloud