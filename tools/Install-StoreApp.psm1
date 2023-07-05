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

Export-ModuleMember -Function Install-StoreApp