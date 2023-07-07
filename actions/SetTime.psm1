function SetTime {
    Write-Host "Setting Time zone..." -ForegroundColor Green
    Set-TimeZone -Id "UTC"
    Write-Host "Time zone set to UTC."

    Write-Host "Syncing time..." -ForegroundColor Green
    net stop w32time
    net start w32time
    w32tm /resync /force
    w32tm /query /status
}

Export-ModuleMember -Function SetTime