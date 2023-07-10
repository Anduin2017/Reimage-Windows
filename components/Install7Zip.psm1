Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path) -DisableNameChecking

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path) -DisableNameChecking


function Install7Zip {
    Install-IfNotInstalled "7zip.7zip"
}

Export-ModuleMember -Function Install7Zip
