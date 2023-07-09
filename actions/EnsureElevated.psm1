Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\tools\Get-IsElevated.psm1" | Resolve-Path)

function EnsureElevated {
    if (-not(Get-IsElevated)) { 
        throw "Please run this script as an administrator" 
    }
    else {
        Write-Host -ForegroundColor DarkGreen "Running as administrator. We can continue."
    }
}

Export-ModuleMember -Function EnsureElevated