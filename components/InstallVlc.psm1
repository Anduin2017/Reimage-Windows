Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallVlc {
    Install-IfNotInstalled "VideoLAN.VLC"
    AddToPath -folder "$env:ProgramFiles\VideoLAN\VLC"
}

Export-ModuleMember -Function InstallVlc