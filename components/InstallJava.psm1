Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path) -DisableNameChecking
Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path) -DisableNameChecking

function InstallJava {
    Install-IfNotInstalled "Microsoft.OpenJDK.17"
}

Export-ModuleMember -Function InstallJava
