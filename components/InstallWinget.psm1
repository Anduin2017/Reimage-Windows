function InstallWinget {
    if (-not $(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Installing WinGet..." -ForegroundColor Green
        Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1&mode=mini"
    
        while (-not $(Get-Command "winget" -ErrorAction SilentlyContinue)) {
            Write-Host "Winget is still not found!" -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
    } else {
        Write-Host "Winget is already installed!" -ForegroundColor DarkGreen
    }
}

Export-ModuleMember -Function InstallWinget