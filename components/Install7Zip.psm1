Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\AddToPath.psm1" | Resolve-Path)


function Install7Zip {
    Install-IfNotInstalled "7zip.7zip"
}

Export-ModuleMember -Function Install7Zip
