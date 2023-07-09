Import-Module (Join-Path -Path $PSScriptRoot -ChildPath "..\tools\DownloadAndExtract.psm1" | Resolve-Path)

function InstallFFmpeg {
    Write-Host "Installing FFmpeg..." -ForegroundColor Green
    $ffmpegLink = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
    DownloadAndExtract -url $ffmpegLink -tempFileName "ffmpeg.7z" -name "FFmpeg"
    $ffmpegPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "FFmpeg"

    $subPath = $(Get-ChildItem -Path $ffmpegPath | Where-Object { $_.Name -like "ffmpeg*" } | Sort-Object Name -Descending | Select-Object -First 1).Name
    Write-Host "FFmpeg version is $subPath..." -ForegroundColor Yellow
    $subPath = Join-Path -Path $ffmpegPath -ChildPath $subPath
    $binPath = Join-Path -Path $subPath -ChildPath "bin"
    Remove-Item "$ffmpegPath\*.exe"
    Move-Item "$binPath\*.exe" $ffmpegPath

    Write-Host "Adding FFmpeg to PATH..." -ForegroundColor Green
    AddToPath -folder $ffmpegPath
}

Export-ModuleMember -Function InstallFFmpeg
