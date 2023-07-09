Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallBlender {
    Install-IfNotInstalled "BlenderFoundation.Blender"
}

Export-ModuleMember -Function InstallBlender
