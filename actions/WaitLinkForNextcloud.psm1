function WaitLinkForNextcloud {
    param(
        [string]$path
    )
    while (-not $(Get-Content -Path $path -ErrorAction SilentlyContinue)) {
        Write-Host "Nextcloud is not ready yet!" -ForegroundColor Yellow
        Start-Sleep -Seconds 15
    }

    Write-Host "Ensure Nextcloud files are readable..."
    Get-Content -Path "$HOME\Nextcloud\Storage\SSH\id_rsa.pub" -ErrorAction SilentlyContinue | Out-Null
    Get-Content -Path "$HOME\Nextcloud\Storage\SSH\id_rsa" -ErrorAction SilentlyContinue | Out-Null
}

Export-ModuleMember -Function WaitLinkForNextcloud