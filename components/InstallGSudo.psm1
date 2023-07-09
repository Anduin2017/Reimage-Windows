Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path)


function InstallGSudo {
    Install-IfNotInstalled "gerardog.gsudo"

    Add-PathToEnv "$env:ProgramFiles\gsudo\Current\"
}

Export-ModuleMember -Function InstallGSudo
