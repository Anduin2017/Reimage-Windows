Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path) -DisableNameChecking

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path) -DisableNameChecking


function InstallNodeJs {
    Install-IfNotInstalled "OpenJS.NodeJS"
    ReloadPath

    Write-Host "Setting up some node js global tools..." -ForegroundColor Green
    npm install --global npm@latest
    if (Get-Command static -ErrorAction SilentlyContinue) {
        Write-Host "static is already installed!" -ForegroundColor Yellow
    } else {
        npm install --global typescript @angular/cli yarn npm-check-updates redis-cli
    }
}

Export-ModuleMember -Function InstallNodeJs