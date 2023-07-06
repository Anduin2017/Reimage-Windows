Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallJava {
    Install-IfNotInstalled "Microsoft.OpenJDK.17"
}

Export-ModuleMember -Function InstallJava
