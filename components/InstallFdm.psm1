Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallFdm {
    Install-IfNotInstalled "SoftDeluxe.FreeDownloadManager"

    Write-Host "Clean up FDM..." -ForegroundColor Green
    Get-Process -Name fdm | Stop-Process
    Remove-Item -Path "$env:LOCALAPPDATA\Softdeluxe" -Force -Recurse -ErrorAction SilentlyContinue

    Write-Host "Start new FDM and kill it..." -ForegroundColor Green
    Start-Process "$env:ProgramFiles\Softdeluxe\Free Download Manager\fdm.exe"
    Start-Sleep -Seconds 5
    Get-Process -Name fdm | Stop-Process

    Write-Host "Replace FDM config files..." -ForegroundColor Green
    $fdmDbPath = "$env:LOCALAPPDATA\Softdeluxe\Free Download Manager\db.sqlite"
    Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/db.sqlite?inline=false" -OutFile "$fdmDbPath"

    Write-Host "Avoid FDM auto start..." -ForegroundColor Green
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Free Download Manager" -Force

    Write-Host "OOBE FDM..." -ForegroundColor Green
    Start-Process "$env:ProgramFiles\Softdeluxe\Free Download Manager\fdm.exe"
    
}

Export-ModuleMember -Function InstallFdm
