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
    $downloadPath = Join-Path -Path $env:TEMP -ChildPath "iperf3.zip"
    Qget $downloadUrl $downloadPath
    
    $installPath = Join-Path -Path $env:ProgramFiles -ChildPath "iperf3"
    Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
    $iperfPath = (Get-ChildItem -Path $installPath -Directory | Sort-Object -Property LastWriteTime -Descending)[0].FullName
    AddToPath -folder $iperfPath
    
    Remove-Item $downloadPath
}

Export-ModuleMember -Function InstallIPerf3