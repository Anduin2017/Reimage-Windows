Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\RemoveUwp.psm1" | Resolve-Path)

function RemoveOneDrive {
    Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Stop-Process
    winget uninstall "Microsoft.OneDrive"
    Remove-Item -Path "$env:ProgramFiles(x86)\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function RemoveOneDrive