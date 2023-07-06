Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallWeChat {
    Install-IfNotInstalled "Tencent.WeChat"

    Write-Host "Disabling WeChat auto start..." -ForegroundColor Green
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\Wechat" -Force
}

Export-ModuleMember -Function InstallWeChat
