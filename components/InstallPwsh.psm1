Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallPwsh {
    Install-IfNotInstalled "Microsoft.PowerShell"
}

Export-ModuleMember -Function InstallPwsh
