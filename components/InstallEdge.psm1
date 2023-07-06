Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallEdge {
    Write-Host "Installing Microsoft Edge as your work browser...`n" -ForegroundColor Green
    Install-IfNotInstalled "Microsoft.Edge"
    Install-IfNotInstalled "Microsoft.EdgeWebView2Runtime"

    Write-Host "Disabling Alt+Tab swiching Edge tabs..." -ForegroundColor Yellow
    New-Item         -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MultiTaskingAltTabFilter -Type DWORD -Value 3 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MultiTaskingAltTabFilter -Type DWORD -Value 3
    
    Write-Host "Avoid Edge showing sidebar..." -ForegroundColor Yellow
    New-Item         -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -ErrorAction SilentlyContinue
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name HubsSidebarEnabled -Type DWORD -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name HubsSidebarEnabled -Type DWORD -Value 0

    Write-Host "Kill Edge to force reload..." -ForegroundColor Yellow
    Get-Process -Name msedge -ErrorAction SilentlyContinue | Stop-Process
}

Export-ModuleMember -Function InstallEdge
