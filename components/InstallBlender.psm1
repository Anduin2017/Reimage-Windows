Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallBlender {
    Install-IfNotInstalled "BlenderFoundation.Blender"
}

Export-ModuleMember -Function InstallBlender
