Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)


function InstallPwsh {
    Install-IfNotInstalled "Microsoft.PowerShell"
}

Export-ModuleMember -Function InstallPwsh
