Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallWindowsTerminal {
    Install-IfNotInstalled "Microsoft.WindowsTerminal"
}

Export-ModuleMember -Function InstallWindowsTerminal
