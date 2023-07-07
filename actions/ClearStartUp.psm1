function ClearStartUp {

    Write-Host "Clearing start up..." -ForegroundColor Green
    $startUp = $env:USERPROFILE + "\Start Menu\Programs\StartUp\*"
    Get-ChildItem $startUp
    Remove-Item -Path $startUp
    Get-ChildItem $startUp
    Write-Host "Start up cleared."
    
}

Export-ModuleMember -Function ClearStartUp