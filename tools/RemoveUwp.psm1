function RemoveUwp {
    param (
        [string]$name
    )

    Write-Host "Removing UWP $name..." -ForegroundColor Green
    Get-AppxPackage $name | Remove-AppxPackage
    Get-AppxPackage $name | Remove-AppxPackage -AllUsers
}

Export-ModuleMember -Function RemoveUwp