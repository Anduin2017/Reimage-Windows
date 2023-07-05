Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallGit {
    Install-IfNotInstalled "Git.Git"
    AddToPath "$env:ProgramFiles\Git\bin\"
}

Export-ModuleMember -Function InstallGit