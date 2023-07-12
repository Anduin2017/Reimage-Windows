function Setup-PowerShellEnvironment {
    Write-Host "Setting execution policy to remotesigned..." -ForegroundColor Green
    Set-ExecutionPolicy remotesigned -Force

    if (-not $(Get-Command Connect-AzureAD -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Nuget PowerShell Package Provider..." -ForegroundColor Green
        Install-PackageProvider -Name NuGet -Force
        Write-Host "Installing AzureAD PowerShell module..." -ForegroundColor Green
        Install-Module AzureAD -Force
    }
    else {
        Write-Host "Azure AD PowerShell Module is already installed!" -ForegroundColor Green
    }
    
    Write-Host "Enabling long path..." -ForegroundColor Green
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

    Write-Host "Ensure profile file exists..."
    if (-not (Test-Path $PROFILE)) {
        New-Item -Type File -Path $PROFILE -Force
    }

    Write-Host "Installing PowerShell tools..." -ForegroundColor Green
    $toolsPath = Join-Path -Path (Join-Path -Path $PROFILE -ChildPath "..\" | Resolve-Path) -ChildPath "Tools"
    New-Item -Type Directory -Path $toolsPath -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path "$env:TEMP\reimage-windows-master\tools\*" -Destination $toolsPath -Recurse -Force

    Write-Host "Installing profile file..." -ForegroundColor Green
    Copy-Item -Path "$env:TEMP\reimage-windows-master\PROFILE.ps1" -Destination $PROFILE
    . $PROFILE
}

Export-ModuleMember -Function Setup-PowerShellEnvironment