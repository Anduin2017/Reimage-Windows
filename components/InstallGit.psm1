Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallGit {
    param(
        [string]$email,
        [string]$name
    )

    Install-IfNotInstalled "Git.Git"
    AddToPath "$env:ProgramFiles\Git\bin\"

    Write-Host "Linking back SSH keys..." -ForegroundColor Green
    $NextcloudSshConfigPath = "$HOME\Nextcloud\Storage\SSH\"
    $localSshConfigPath = "$HOME\.ssh\"

    Remove-Item -Path $localSshConfigPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $localSshConfigPath -Target $NextcloudSshConfigPath -Force

    Write-Host "Testing SSH features..." -ForegroundColor Green
    Write-Host "yes" | ssh -o "StrictHostKeyChecking no" git@github.com

    Write-Host "Configuring git..." -ForegroundColor Green

    $email = $(git config --global user.email)
    $name = $(git config --global user.name)
    
    if (-not $email) {
        $email = Read-Host "Please enter your email address"
        git config --global user.email $email
    }
    
    if (-not $name) {
        $name = Read-Host "Please enter your name"
        git config --global user.name $name
    }

    git config --global core.autocrlf true
    git config --global core.longpaths true
    git config --global --add safe.directory '*'
}

Export-ModuleMember -Function InstallGit