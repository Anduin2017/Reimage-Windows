function InstallAdb {

    Write-Host "Downloading Android-Platform-Tools..." -ForegroundColor Green
    $adbLink = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    DownloadAndExtract -url $adbLink -tempFileName "android-tools.zip" -name "Android"
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Android\platform-tools"
    AddToPath -folder $installPath
}

Export-ModuleMember -Function InstallAdb
