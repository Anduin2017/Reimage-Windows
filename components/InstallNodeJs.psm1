Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallNodeJs {
    Install-IfNotInstalled "OpenJS.NodeJS"
    ReloadPath

    Write-Host "Setting up some node js global tools..." -ForegroundColor Green
    npm install --global npm@latest
    npm install --global node-static typescript @angular/cli yarn npm-check-updates redis-cli
}

Export-ModuleMember -Function InstallNodeJs