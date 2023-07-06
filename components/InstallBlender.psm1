Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallBlender {
    Install-IfNotInstalled "BlenderFoundation.Blender"
}

Export-ModuleMember -Function InstallBlender
