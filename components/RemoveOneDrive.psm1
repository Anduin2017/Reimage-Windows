Import-Module "..\tools\RemoveUwp.psm1"

function RemoveOneDrive {
    winget remove "Microsoft.OneDrive"
    Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Stop-Process
    Remove-Item -Path "$env:ProgramFiles(x86)\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function RemoveOneDrive