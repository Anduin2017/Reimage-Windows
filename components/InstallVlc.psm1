Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path)


function InstallVlc {
    Install-IfNotInstalled "VideoLAN.VLC"
    Add-PathToEnv -folder "$env:ProgramFiles\VideoLAN\VLC"
}

Export-ModuleMember -Function InstallVlc