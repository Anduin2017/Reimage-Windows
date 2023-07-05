Import-Module ".\tools\Get-IsElevated.psm1"

function EnsureElevated {
    if (-not(Get-IsElevated)) { 
        throw "Please run this script as an administrator" 
    }
}

Export-ModuleMember -Function EnsureElevated