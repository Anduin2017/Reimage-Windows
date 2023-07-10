Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Download-AndExtract.psm1" | Resolve-Path) -DisableNameChecking


function Get-LatestIperf3Version {
    $apiUrl = "https://iperf.fr/iperf-download.php"
    $downloadAddress = (Invoke-WebRequest -Uri $apiUrl).Links |
    Where-Object { $_.href -like "download/windows/iperf-*-win64.zip" } |
    Select-Object -ExpandProperty href |
    Sort-Object { $_ -replace ".iperf-(.)-win64.zip", '$1' } -Descending |
    Select-Object -First 1
    
    $downloadUrl = "https://iperf.fr/$downloadAddress"
    return $downloadUrl
}


function InstallIPerf3 {
    Write-Host "Installing iperf3.."  -ForegroundColor Green
    $downloadUrl = Get-LatestIperf3Version
    Download-AndExtract -url $downloadUrl -tempFileName "iperf3.zip" -name "IPerf"
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "IPerf"
    $iperfPath = (Get-ChildItem -Path $installPath -Directory | Sort-Object -Property LastWriteTime -Descending)[0].FullName
    Add-PathToEnv -folder $iperfPath
}

Export-ModuleMember -Function InstallIPerf3