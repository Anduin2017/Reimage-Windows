function ManualDoNext {
    Write-Host "This script is for Anduin to prepare an ready-to-use Windows environment. Based on a new clean Windows.`n" -ForegroundColor DarkMagenta
    Write-Host "Even this is an automation script to prepare the Windows, there are still several items requires manual operation:`n" -ForegroundColor Yellow
    Write-Host " * Change your display scale and resolution." -ForegroundColor White
    Write-Host " * Set default browser to Edge(work) or Chrome(personal)." -ForegroundColor White
    Write-Host " * Sign in VSCode and GitHub to turn on settings sync." -ForegroundColor White
    Write-Host " * Open office once." -ForegroundColor White
    Write-Host " * Sign in Mail UWP." -ForegroundColor White
    Write-Host " * Sign in WeChat and change shortcut" -ForegroundColor White
    Write-Host " * Sign in Youtube and Google" -ForegroundColor White
    Write-Host " * (Optional)Manually install latest NVIDIA drivers" -ForegroundColor White
    Write-Host " * Sign in https://gitlab.aiursoft.cn" -ForegroundColor White
    Write-Host " * Install V2rayN" -ForegroundColor White
    Write-Host " * (Optional) Download and sign in ASUS Armoury Crate" -ForegroundColor White
    Write-Host " * (Optional) Sync NVIDIA Geforce experience settings and set shortcuts" -ForegroundColor White
    Write-Host " * (Optional) Run HDR Caliboration https://apps.microsoft.com/store/detail/windows-hdr-calibration/9N7F2SM5D1LR" -ForegroundColor White
}

Export-ModuleMember -Function ManualDoNext