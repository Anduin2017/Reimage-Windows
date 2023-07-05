Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallVlc {
    Install-IfNotInstalled "VideoLAN.VLC"
    AddToPath -folder "$env:ProgramFiles\VideoLAN\VLC"
}

Export-ModuleMember -Function InstallVlc