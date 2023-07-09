Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Install-IfNotInstalled.psm1" | Resolve-Path)

Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\AddToPath.psm1" | Resolve-Path)


function InstallGSudo {
    Install-IfNotInstalled "gerardog.gsudo"

    AddToPath "$env:ProgramFiles\gsudo\Current\"
}

Export-ModuleMember -Function InstallGSudo
