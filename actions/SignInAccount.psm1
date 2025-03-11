function SignInAccount {
    if (-not $(Get-Content -Path "$HOME\Nextcloud\Private\SSH\id_rsa.pub" -ErrorAction SilentlyContinue)) {
        Write-Host "Nextcloud is not singed in yet!" -ForegroundColor Yellow
        Write-Host "Right here, please sign in your Nextcloud account and passwords account. So you can unlock Nextcloud and GitHub."
        Start-Sleep -Seconds 2
        Start-Process "https://nextcloud.aiursoft.cn/index.php/apps/passwords/"
    }

}

Export-ModuleMember -Function SignInAccount