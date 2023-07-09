Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallJava {
    Install-IfNotInstalled "Microsoft.OpenJDK.17"
}

Export-ModuleMember -Function InstallJava
