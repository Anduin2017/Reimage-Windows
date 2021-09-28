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
    $allVideos = Get-ChildItem -Path . -Include ('*.wmv', '*.avi', '*.mp4') -Recurse -ErrorAction SilentlyContinue -Force
    while ($true) {
        $pickedVideo = $(Get-Random -InputObject $allVideos).FullName
        Write-Host "Picked to play $pickedVideo" -ForegroundColor Yellow
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--start-time 9 $pickedVideo" -Wait
    }
}

