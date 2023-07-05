Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallAzureDataStudio {
    Install-IfNotInstalled "Microsoft.AzureDataStudio"
}

Export-ModuleMember -Function InstallAzureDataStudio
