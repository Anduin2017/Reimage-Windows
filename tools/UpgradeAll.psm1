function UpgradeAll {
    # Upgrade all.
    Write-Host "Checking for final app upgrades..." -ForegroundColor Green
    winget upgrade --all --source winget
}

Export-ModuleMember -Function UpgradeAll