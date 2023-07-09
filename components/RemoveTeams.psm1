Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\RemoveUwp.psm1" | Resolve-Path)

function RemoveTeams {
    Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process
    RemoveUwp MicrosoftTeams
    winget remove "Microsoft.Teams"
    winget remove "Teams Machine-Wide Installer"
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\TeamsPresenceAddin" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles(x86)\Teams Installer" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:APPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramData\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue

}

Export-ModuleMember -Function RemoveTeams