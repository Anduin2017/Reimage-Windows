Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\RemoveUwp.psm1" | Resolve-Path) -DisableNameChecking

function RemoveTeams {
    Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process
    RemoveUwp MicrosoftTeams
    winget uninstall "Microsoft.Teams"
    winget uninstall "Teams Machine-Wide Installer"

    # Kill Teams
    Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process

    # Remove Teams
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:APPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramData\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles(x86)\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\TeamsPresenceAddin" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles(x86)\Teams Installer" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:APPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramData\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Hide chat button on task bar..." -ForegroundColor Green
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarMn -Value 0 -PropertyType DWORD -Force
    Write-Host "Chat button on taskbar was disabled."
}

Export-ModuleMember -Function RemoveTeams