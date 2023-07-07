function SetupNetwork {
    $networkProfiles = Get-NetConnectionProfile
    foreach ($networkProfile in $networkProfiles) {
        Write-Host "Setting network $($networkProfile.Name) to home network to enable more features..." -ForegroundColor Green
        Write-Host "This is dangerous because your roommates may detect your device is online." -ForegroundColor Yellow
        Set-NetConnectionProfile -Name $networkProfile.Name -NetworkCategory Private
    }
}

Export-ModuleMember -Function SetupNetwork