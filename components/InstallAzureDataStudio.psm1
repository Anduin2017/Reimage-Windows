Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path) -DisableNameChecking


function InstallAzureDataStudio {
    Install-IfNotInstalled "Microsoft.AzureDataStudio"
}

Export-ModuleMember -Function InstallAzureDataStudio
