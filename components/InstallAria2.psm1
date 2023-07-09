Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\AddToPath.psm1" | Resolve-Path)


function InstallAria2 {
    #aria2
    Write-Host "Installing aria2 as download tool..." -ForegroundColor Green

    $apiUrl = "https://api.github.com/repos/aria2/aria2/releases/latest"
    $downloadAddress = (Invoke-RestMethod -Uri $apiUrl).assets`
        | Where-Object { $_.name -like "aria2-*-win-64bit-build1.zip" }`
        | Select-Object -ExpandProperty browser_download_url
    Write-Host "Downloading aria2 from: $downloadAddress" -ForegroundColor Yellow

    $aria2ZipPath = Join-Path -Path $env:TEMP -ChildPath "aria2.zip"
    Invoke-WebRequest $downloadAddress -OutFile $aria2ZipPath

    $installPath = "${env:ProgramFiles}\aria2"
    New-Item -ItemType Directory -Force -Path $installPath | Out-Null

    Expand-Archive -LiteralPath $aria2ZipPath -DestinationPath $installPath -Force

    $subPath = Get-ChildItem -Path $installPath | Where-Object { $_.Name -like "aria2-*" } | Sort-Object Name -Descending | Select-Object -First 1
    $fullSubPath = Join-Path -Path $installPath -ChildPath $subPath.Name
    Move-Item -Path "$fullSubPath\*" -Destination $installPath -Force
    Remove-Item -Path $fullSubPath -Recurse -Force

    AddToPath -folder $installPath
    Remove-Item -Path $aria2ZipPath -Force
}

Export-ModuleMember -Function InstallAria2