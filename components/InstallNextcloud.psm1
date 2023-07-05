Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallNextcloud {
    Install-IfNotInstalled "Nextcloud.NextcloudDesktop"
}

Export-ModuleMember -Function InstallNextcloud