Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\Download-AndExtract.psm1" | Resolve-Path)

function InstallAdb {

    Write-Host "Downloading Android-Platform-Tools..." -ForegroundColor Green
    $adbLink = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    Download-AndExtract -url $adbLink -tempFileName "android-tools.zip" -name "Android"
    $installPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Android\platform-tools"
    Add-PathToEnv -folder $installPath
}

Export-ModuleMember -Function InstallAdb
