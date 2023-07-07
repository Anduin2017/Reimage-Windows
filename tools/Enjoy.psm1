# Description: Play all videos in a folder in random order
function Enjoy {
    Write-Host "Fetching videos..."
    $allVideos = Get-ChildItem -Path . -Include ('*.wmv', '*.avi', '*.mp4', '*.webm') -Recurse -ErrorAction SilentlyContinue -Force
    $allVideos = $allVideos | Sort-Object { Get-Random }
    Write-Host "Playing $($allVideos.Count) videos..."
    foreach ($pickedVideo in $allVideos) {
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--no-repeat --play-and-exit --no-video-title-show --start-time=5 --fullscreen --rate 1.5 `"$pickedVideo`"" -Wait 2>&1 | out-null
    }
}

Export-ModuleMember -Function Enjoy