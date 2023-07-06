function ResetNet {
    Write-Host "Reseting Network...(ETA: 20 seconds...)" -ForegroundColor Green
    ipconfig /release
    ipconfig /flushdns
    ipconfig /renew
    netsh int ip reset
    netsh winsock reset
    route /f
    netcfg -d
    sc config FDResPub start=auto
    sc config fdPHost start=auto
    shutdown -r -t 10
    Start-Sleep -Seconds 3
}

Export-ModuleMember -Function ResetNet