Import-Module "..\tools\RemoveUwp.psm1"

function RemoveOneDrive {
    winget remove "Microsoft.OneDrive"
    Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramFiles(x86)\Teams Installer" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:APPDATA\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:ProgramData\Microsoft\Teams" -Recurse -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function RemoveOneDrive