function InstallOffice {
    if ("$(winget list -e --id Microsoft.Office --source winget)".Contains("--")) { 
        Write-Host "Microsoft.Office is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: Microsoft.Office..." -ForegroundColor Green
        Start-Process powershell {
            winget install -e --id Microsoft.Office --source winget
        }
    }
}

Export-ModuleMember -Function InstallOffice
