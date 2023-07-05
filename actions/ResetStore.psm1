function ResetStore {
    Write-Host "Reseting Store...(ETA: 20 seconds...)" -ForegroundColor Green
    wsreset.exe -i
    Start-Sleep -Seconds 3
}

Export-ModuleMember -Function ResetStore