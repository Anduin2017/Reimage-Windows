Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallAzureDataStudio {
    Install-IfNotInstalled "Microsoft.AzureDataStudio"
}

Export-ModuleMember -Function InstallAzureDataStudio
