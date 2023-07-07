Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallNodeJs {
    Install-IfNotInstalled "OpenJS.NodeJS"
    ReloadPath

    Write-Host "Setting up some node js global tools..." -ForegroundColor Green
    npm install --global npm@latest
    if (Get-Command static -ErrorAction SilentlyContinue) {
        Write-Host "static is already installed!" -ForegroundColor Green
    } else {
        npm install --global node-static typescript @angular/cli yarn npm-check-updates redis-cli
    }
}

Export-ModuleMember -Function InstallNodeJs