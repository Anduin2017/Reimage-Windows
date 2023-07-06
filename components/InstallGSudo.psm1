Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallGSudo {
    Install-IfNotInstalled "gerardog.gsudo"
}

Export-ModuleMember -Function InstallGSudo
