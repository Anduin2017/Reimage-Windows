function Qget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$address,
        [string]$path = ""
    )

    if ($path -eq "") {
        $path = ".\$(Split-Path -Leaf $address)"
    }

    Write-Host "Downloading file $address to $path with aria2c..." -ForegroundColor Yellow
    $aria2cArgs = "-c -s 128 -x 8 -k 4M -j 128 --split 128 `"$address`" -d `"$([System.IO.Path]::GetDirectoryName($path))`" -o `"$([System.IO.Path]::GetFileName($path))`" --check-certificate=false --quiet=true"
    Invoke-Expression "aria2c.exe $aria2cArgs"
}

Export-ModuleMember -Function Qget
