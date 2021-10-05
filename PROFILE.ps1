# PROFILE FILE

Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

function Update-All {
    # This will start a new PowerShell window outside Windows terminal with Admin permission.
    Start-Process "PowerShell.exe" -PassThru "Force-UpdateAll" -Verb RunAs
}

function Force-UpdateAll {
    # This will run this update script inside current terminal.
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://github.com/Anduin2017/configuration-script-win/raw/main/install.ps1"))
}

function Watch-RandomVideo {
    Write-Host "Fetching videos..."
    $allVideos = Get-ChildItem -Path . -Include ('*.wmv', '*.avi', '*.mp4') -Recurse -ErrorAction SilentlyContinue -Force
    $allVideos = $allVideos | Sort-Object { Get-Random }
    $allVideos | Format-Table -AutoSize | Select-Object -First 20
    Write-Host "Playing $($allVideos.Count) videos..."
    foreach ($pickedVideo in $allVideos) {
        # $pickedVideo = $(Get-Random -InputObject $allVideos).FullName
        Write-Host "Picked to play $pickedVideo" -ForegroundColor Yellow
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--start-time 9 `"$pickedVideo`"" -Wait
    }
}

function Watch-RandomPhoto {
    Write-Host "Fetching photos..."
    $allPhotos = Get-ChildItem -Path . -Include ('*.jpg', '*.png', '*.bmp') -Recurse -ErrorAction SilentlyContinue -Force
    $allPhotos = $allPhotos | Sort-Object { Get-Random }
    $allPhotos | Format-Table -AutoSize | Select-Object -First 20
    Write-Host "Playing $($allPhotos.Count) photos..."
    foreach ($pickedPhoto in $allPhotos) {
        # $pickedVideo = $(Get-Random -InputObject $allVideos).FullName
        Write-Host "Picked to play $pickedPhoto" -ForegroundColor Yellow
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--start-time 5 `"$pickedPhoto`" --fullscreen"
        Start-Sleep -Seconds 4
    }
}
