Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallOffice {
    Install-IfNotInstalled "Microsoft.Office"
}

Export-ModuleMember -Function InstallOffice
