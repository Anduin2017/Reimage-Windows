Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallWeChat {
    Install-IfNotInstalled "Tencent.WeChat"

    Write-Host "Disabling WeChat auto start..." -ForegroundColor Green
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\Wechat" -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function InstallWeChat
