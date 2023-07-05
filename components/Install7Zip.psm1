Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function Install7Zip {
    Install-IfNotInstalled "7zip.7zip"
}

Export-ModuleMember -Function Install7Zip
