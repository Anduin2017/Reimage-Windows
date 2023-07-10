Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path) -DisableNameChecking

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path) -DisableNameChecking


function InstallBlender {
    Install-IfNotInstalled "BlenderFoundation.Blender"
}

Export-ModuleMember -Function InstallBlender
