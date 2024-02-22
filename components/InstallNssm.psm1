Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Download-AndExtract.psm1" | Resolve-Path) -DisableNameChecking
Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Add-PathToEnv.psm1" | Resolve-Path) -DisableNameChecking

function InstallNssm {
    $downloadAddress = "https://nssm.cc/release/nssm-2.24.zip"
    Write-Host "Downloading nssm from: $downloadAddress" -ForegroundColor Yellow
    Download-AndExtract -url $downloadAddress -tempFileName "nssm.zip" -name "nssm"
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "nssm\nssm-2.24\win64\"
    Add-PathToEnv -folder $installPath
}

Export-ModuleMember -Function InstallNssm
