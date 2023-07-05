function Install-IfNotInstalled {
    param (
        [string]$package
    )

    if ("$(winget list -e --id $package --source winget)".Contains("--")) { 
        Write-Host "$package is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: $package..." -ForegroundColor Green
        try {
            winget install -e --id $package --source winget --scope Machine
        } catch {
            Write-Warning "Failed to install $package as machine scope. Try user scope! $_"
            winget install -e --id $package --source winget
        }
    }
}

Export-ModuleMember -Function Install-IfNotInstalled