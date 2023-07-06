
function ClearRecycleBin {
    Write-Host "Clearing recycle bin..." -ForegroundColor Green
    $sysDrive = (get-location).Drive.Name
    Clear-RecycleBin -DriveLetter $sysDrive -Force -Confirm
    Write-Host "Recycle bin cleared on $sysDrive..."
}

Export-ModuleMember -Function ClearRecycleBin