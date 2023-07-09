Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\DownloadAndExtract.psm1" | Resolve-Path)


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

    $wgetLink = GetWgetLink
    DownloadAndExtract -url $wgetLink -tempFileName "wget.zip" -name "Wget"
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Wget"
    AddToPath -folder $installPath
}

Export-ModuleMember -Function InstallWget