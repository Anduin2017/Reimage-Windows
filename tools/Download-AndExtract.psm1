
Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\Qget.psm1" | Resolve-Path) -DisableNameChecking

function Download-AndExtract {
    param(
        [string]$url,
        [string]$tempFileName,
        [string]$name
    )
    $OutputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
    Write-Host "Download $name from $url.."  -ForegroundColor Yellow

    $downloadPath = Join-Path -Path $env:TEMP -ChildPath $tempFileName
    Qget $url $downloadPath
    
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath $name

    $7ZipPath = "${env:ProgramFiles}\7-Zip\7z.exe"
    $arguments = "x", $downloadPath, "-o$($installPath)", "-y", "-bso0", "-bsp0"
    Start-Process -FilePath $7ZipPath -ArgumentList $arguments -Wait -NoNewWindow
    
    
    Remove-Item $downloadPath
    Write-Host "$name was downloaded and put as $installPath"  -ForegroundColor Yellow
}

Export-ModuleMember -Function Download-AndExtract