function UpgradeAll {
    # Upgrade all.
    Write-Host "Checking for final app upgrades..." -ForegroundColor Green
    winget upgrade --all --source winget

    # Add git again. Because git may remove it.
    AddToPath "$env:ProgramFiles\Git\bin\"
}

Export-ModuleMember -Function UpgradeAll