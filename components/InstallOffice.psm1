Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallOffice {
    Start-Process powershell {
        Import-Module "..\tools\Install-IfNotInstalled.psm1"
        Install-IfNotInstalled "Microsoft.Office"
    }
}

Export-ModuleMember -Function InstallOffice
