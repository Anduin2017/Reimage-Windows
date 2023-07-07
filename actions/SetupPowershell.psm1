function SetupPowershell {
    Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Green
    Set-ExecutionPolicy remotesigned -Force

    Write-Host "Enabling long path..." -ForegroundColor Green
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

    Write-Host "Installing profile file..." -ForegroundColor Green
    if (!(Test-Path $PROFILE)) {
        Write-Host "Creating PROFILE..." -ForegroundColor Yellow
        New-Item -Path $PROFILE -ItemType "file" -Force
    }
    $profileContent = (New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/PROFILE.ps1')
    Set-Content $PROFILE $profileContent
    . $PROFILE
}

Export-ModuleMember -Function SetupPowershell