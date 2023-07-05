Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallGit {
    param(
        [string]$mail
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
        git config --global user.email $mail
    }
    
    if (-not $name) {
        $name = $env:USERNAME
        git config --global user.name $name
    }

    $email = $(git config --global user.email)
    $name = $(git config --global user.name)
    Write-Host "Git Email was set to $email." -ForegroundColor Yellow
    Write-Host "Git name was set to $name." -ForegroundColor Yellow

    git config --global core.autocrlf true
    git config --global core.longpaths true
    git config --global --add safe.directory '*'

    if (-not $(Get-Command git-lfs)) {
        winget install "GitHub.GitLFS" --source winget
    }
    else {
        Write-Host "Git LFS is already installed." -ForegroundColor Yellow
    }
}

Export-ModuleMember -Function InstallGit