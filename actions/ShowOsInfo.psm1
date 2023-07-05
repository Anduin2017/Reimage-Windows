function ShowOsInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "`nOS Name:" -ForegroundColor Green
    $os.Name
    Write-Host "`nOS Install Date:" -ForegroundColor Green
    $os.InstallDate
    Write-Host "`nOS Architecture:" -ForegroundColor Green
    $os.OSArchitecture
    Write-Host "`nCPU Info:" -ForegroundColor Green
    (Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0\).ProcessorNameString
    Write-Host "`nRAM Size:" -ForegroundColor Green
    Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | ForEach-Object { "{0:N2}" -f ($_.Sum / 1GB) + " GB" }
    Write-Host "`nSystem Disk Size:" -ForegroundColor Green
    Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($(Get-Location).Drive.Name):'" | Measure-Object -Property Size -Sum | ForEach-Object { "{0:N2}" -f ($_.Sum / 1GB) + " GB" }
    $screen = (Get-WmiObject -Class Win32_VideoController)
    $screenX = $screen.CurrentHorizontalResolution
    $screenY = $screen.CurrentVerticalResolution
    Write-Host "`nScreen Resolution:" -ForegroundColor Green
    "$screenX x $screenY"
}

Export-ModuleMember -Function ShowOsInfo