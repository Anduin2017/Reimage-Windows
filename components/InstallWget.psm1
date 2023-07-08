function GetWgetLink {
    # 获取最新版本的 wget 下载链接
    $url = "https://eternallybored.org/misc/wget/releases/"
    $html = Invoke-WebRequest -Uri $url
    $latest = $html.Links | Where-Object { $_.href -like "wget-*-win64.zip" } | Select-Object -First 1
    $downloadUrl = $url + $latest.href
    return $downloadUrl
}

function InstallWget {
    Write-Host "Downloading Wget..." -ForegroundColor Green
    $wgetPath = "${env:ProgramFiles}\wget"

    $wgetLink = GetWgetLink
    $downloadedWget = $env:USERPROFILE + "\wget.zip"
    Remove-Item $downloadedWget -ErrorAction SilentlyContinue
    aria2c.exe $wgetLink -d $HOME -o "wget.zip" --check-certificate=false
        
    & ${env:ProgramFiles}\7-Zip\7z.exe x $downloadedWget "-o$($wgetPath)" -y
    Write-Host "Adding wget to PATH..." -ForegroundColor Green
    AddToPath -folder $wgetPath
    Remove-Item -Path $downloadedWget -Force
}

Export-ModuleMember -Function InstallWget