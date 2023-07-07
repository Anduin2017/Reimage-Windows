function SetupRDP {
    Write-Host "Enable Remote Desktop..." -ForegroundColor Green
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

Export-ModuleMember -Function SetupRDP