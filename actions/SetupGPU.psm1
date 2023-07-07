function SetupGPU {
    Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor Green
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force
}

Export-ModuleMember -Function SetupGPU
