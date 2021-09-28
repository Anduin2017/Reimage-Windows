# PROFILE FILE

Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

function Update-All {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
        Start-Process "PowerShell.exe" -PassThru "Update-AllThisTerminal" -Verb RunAs;
        exit 
    }
    Start-Process "PowerShell.exe" -PassThru "Update-AllThisTerminal" -Verb RunAs
}

function Update-AllThisTerminal {
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

