Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallGit {
    Install-IfNotInstalled "Git.Git"
    AddToPath "$env:ProgramFiles\Git\bin\"

    Write-Host "Linking back SSH keys..." -ForegroundColor Green
    $NextcloudSshConfigPath = "$HOME\Nextcloud\Storage\SSH\"
    $localSshConfigPath = "$HOME\.ssh\"

    Remove-Item -Path $localSshConfigPath -Recurse -Force
    New-Item -ItemType SymbolicLink -Path $localSshConfigPath -Target $NextcloudSshConfigPath -Force

    Write-Host "Testing SSH features..." -ForegroundColor Green
    Write-Host "yes" | ssh -o "StrictHostKeyChecking no" git@github.com

    Write-Host "Configuring git..." -ForegroundColor Green
    Write-Host "Setting git email to $email" -ForegroundColor Yellow
    Write-Host "Setting git name to $name" -ForegroundColor Yellow
    git config --global user.email $email
    git config --global user.name $name
    git config --global core.autocrlf true
    git config --global core.longpaths true
    git config --global --add safe.directory '*'
}

Export-ModuleMember -Function InstallGit