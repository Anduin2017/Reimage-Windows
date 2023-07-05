
Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallDotnet {
    Install-IfNotInstalled "Microsoft.DotNet.SDK.6"
}

Export-ModuleMember -Function InstallDotnet