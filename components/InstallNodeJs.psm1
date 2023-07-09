Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallNodeJs {
    Install-IfNotInstalled "OpenJS.NodeJS"
    ReloadPath

    Write-Host "Setting up some node js global tools..." -ForegroundColor Green
    npm install --global npm@latest
    if (Get-Command static -ErrorAction SilentlyContinue) {
        Write-Host "static is already installed!" -ForegroundColor Yellow
    } else {
        npm install --global node-static typescript @angular/cli yarn npm-check-updates redis-cli
    }
}

Export-ModuleMember -Function InstallNodeJs