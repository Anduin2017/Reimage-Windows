Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallJava {
    Install-IfNotInstalled "Microsoft.OpenJDK.17"
}

Export-ModuleMember -Function InstallJava
