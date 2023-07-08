# Description: Play all videos in a folder in random order
function FixDisk {
    Write-Host "Scanning missing dlls..." -ForegroundColor Green
    sfc /scannow
    Write-Host Y | chkdsk "$($env:SystemDrive)" /f /r /x
}

Export-ModuleMember -Function FixDisk