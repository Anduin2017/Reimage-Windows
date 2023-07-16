function SetupPower {
    Write-Host "Setting Power Policy to ultimate..." -ForegroundColor Green
    powercfg /s e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg /list
    
    Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
    Powercfg /Change monitor-timeout-ac 20
    Powercfg /Change standby-timeout-ac 0
    Write-Host "Monitor timeout set to 20."

    Write-Host "Enabling Hibernate..." -ForegroundColor Green
    powercfg /hibernate on
    Write-Host "Hibernate enabled."

    Write-Host "Setting hibernate mode to full..." -ForegroundColor Green
    powercfg /hibernate /type full
    Write-Host "Hibernate mode set to full."
}

Export-ModuleMember -Function SetupPower