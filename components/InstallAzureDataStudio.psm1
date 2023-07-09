Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallAzureDataStudio {
    Install-IfNotInstalled "Microsoft.AzureDataStudio"
}

Export-ModuleMember -Function InstallAzureDataStudio
