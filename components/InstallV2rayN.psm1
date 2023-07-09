Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\DownloadAndExtract.psm1" | Resolve-Path)
Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\CreateShortcut.psm1" | Resolve-Path)

function GetV2rayNLink {
    $repoUrl = "https://api.github.com/repos/2dust/v2rayN/releases/latest"
    $release = Invoke-RestMethod $repoUrl
    $asset = $release.assets | Where-Object { $_.name -eq "v2rayN-With-Core.zip" }
    $downloadUrl = $asset.browser_download_url
    return $downloadUrl
}

function InstallV2rayN {
    Write-Host "Downloading V2rayN..." -ForegroundColor Green
    
    $v2rayNlink = GetV2rayNLink
    DownloadAndExtract -url $v2rayNlink -tempFileName "v2ray.zip" -name "V2rayN"
    CreateShortcut -path "${env:LOCALAPPDATA}\V2rayN\v2rayN-With-Core\v2rayN.exe" -name "V2ray"
}

Export-ModuleMember -Function InstallV2rayN