function Upgrade-AllApplications {
    # Upgrade all.
    Write-Host "Checking for final app upgrades..." -ForegroundColor Green
    winget upgrade --all --source winget

    # Add git again. Because git may remove it.
    Add-PathToEnv "$env:ProgramFiles\Git\bin\"
}

Export-ModuleMember -Function Upgrade-AllApplications