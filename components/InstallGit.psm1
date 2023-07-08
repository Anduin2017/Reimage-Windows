Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"
Import-Module "..\actions\WaitLinkForNextcloud.psm1"

function InstallGit {
    param(
        [string]$mail
    )

    Install-IfNotInstalled "Git.Git"
    AddToPath "$env:ProgramFiles\Git\bin\"

    WaitLinkForNextcloud -path "$HOME\Nextcloud\Storage\SSH\id_rsa.pub"
    WaitLinkForNextcloud -path "$HOME\Nextcloud\Storage\SSH\id_rsa"
    Write-Host "Linking back SSH keys..." -ForegroundColor Green
    $NextcloudSshConfigPath = "$HOME\Nextcloud\Storage\SSH\"
    $localSshConfigPath = "$HOME\.ssh\"

    Remove-Item -Path $localSshConfigPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $localSshConfigPath -Target $NextcloudSshConfigPath -Force -ErrorAction SilentlyContinue | Out-Null

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

    Write-Host "Configuring bash profile and bash rc..." -ForegroundColor Green
    $bashProfile = "# generated by reimage.aiurs.co
    test -f ~/.profile && . ~/.profile
    test -f ~/.bashrc && . ~/.bashrc"
    Set-Content -Path "$env:HOMEPATH\.bash_profile" -Value $bashProfile
    $bashRC = "# generated by reimage.aiurs.co
    alias qget=`"aria2c.exe -c -s 16 -x 16 -k 1M -j 16`"
    alias sudo=`"gsudo`"
    alias redis-cli=`"rdcli`""
    Set-Content -Path "$env:HOMEPATH\.bashrc" -Value $bashRC

    if (-not $(Get-Command git-lfs)) {
        winget install "GitHub.GitLFS" --source winget
    }
    else {
        Write-Host "Git LFS is already installed." -ForegroundColor Yellow
    }
}

Export-ModuleMember -Function InstallGit