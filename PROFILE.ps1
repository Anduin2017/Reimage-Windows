# PROFILE FILE

Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

Import-Module 'C:\Program Files (x86)\gsudo\gsudoModule.psd1'
Set-Alias 'sudo' 'gsudo'

function Update-All {
    # This will start a new PowerShell window outside Windows terminal with Admin permission.
    Start-Process "PowerShell.exe" -PassThru "Force-UpdateAll" -Verb RunAs
}

function View-Context {
    $(Invoke-WebRequest https://raw.githubusercontent.com/Anduin2017/configuration-script-win/main/test_env.sh  -UseBasicParsing).Content | bash
}

function Force-UpdateAll {
    # This will run this update script inside current terminal.
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://github.com/Anduin2017/configuration-script-win/raw/main/install.ps1"))
}

function Reimage {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/Reimage.ps1'))
}

function Enjoy {
    Write-Host "Fetching videos..."
    $allVideos = Get-ChildItem -Path . -Include ('*.wmv', '*.avi', '*.mp4', '*.webm') -Recurse -ErrorAction SilentlyContinue -Force
    $allVideos = $allVideos | Sort-Object { Get-Random }
    Write-Host "Playing $($allVideos.Count) videos..."
    foreach ($pickedVideo in $allVideos) {
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--start-time 0.5 --fullscreen --rate 1.5 `"$pickedVideo`"" -Wait 2>&1 | out-null
    }
}

function Watch-RandomVideo {
    param(
        [string]$filter,
        [string]$exclude,
        [int]$take = 99999999,
        [bool]$auto = $false
    )

    Write-Host "Fetching videos..."
    $allVideos = Get-ChildItem -Path . -Include ('*.wmv', '*.avi', '*.mp4', '*.webm') -Recurse -ErrorAction SilentlyContinue -Force
    $allVideos = $allVideos | Sort-Object { Get-Random } | Where-Object { $_.VersionInfo.FileName.Contains($filter) }
    if (-not ([string]::IsNullOrEmpty($exclude))) {
        $allVideos = $allVideos | Where-Object { -not $_.VersionInfo.FileName.Contains($exclude) }
    }
    $allVideos = $allVideos | Select-Object -First $take
    $allVideos | Format-Table -AutoSize | Select-Object -First 20
    Write-Host "Playing $($allVideos.Count) videos..."
    foreach ($pickedVideo in $allVideos) {
        # $pickedVideo = $(Get-Random -InputObject $allVideos).FullName
        Write-Host "Picked to play: " -ForegroundColor Yellow -NoNewline
        Write-Host "$pickedVideo" -ForegroundColor White

        $recordedVideos = Get-ChildItem -Path "$env:USERPROFILE\Videos"
        $pickedVideoName = $pickedVideo.Name
        if (($recordedVideos | Where-Object {$_.Name.EndsWith("-$pickedVideoName-.mp4") } | Measure-Object).Count -gt 0) {
            Write-Host "This video you have records!" -ForegroundColor DarkMagenta -NoNewline
        }

        if ($auto -eq $false) {
            Start-Sleep -Seconds 1
        }
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--start-time 9 `"$pickedVideo`"" -Wait 2>&1 | out-null

        if ($auto -eq $false) {
            $vote = Read-Host "How do you like that? (A-B-C-D E-F-G)"
            if (-not ([string]::IsNullOrEmpty($vote))) {
                $destination = "Sorted-Level-$vote"
                Write-Host "Moving $pickedVideo to $destination..." -ForegroundColor Green
                New-Item -Type "Directory" -Name $destination -ErrorAction SilentlyContinue
                Move-Item -Path $pickedVideo -Destination $destination
            }
        }
    }
}

function Watch-RandomPhoto {
    param(
        [string]$filter,
        [int]$take = 99999999
    )
    
    Write-Host "Fetching photos..."
    $allPhotos = Get-ChildItem -Path . -Include ('*.jpg', '*.png', '*.bmp') -Recurse -ErrorAction SilentlyContinue -Force
    $allPhotos = $allPhotos | Sort-Object { Get-Random } | Where-Object { $_.VersionInfo.FileName.Contains($filter) } | Select-Object -First $take
    $allPhotos | Format-Table -AutoSize | Select-Object -First 20
    Write-Host "Playing $($allPhotos.Count) photos..."
    foreach ($pickedPhoto in $allPhotos) {
        # $pickedVideo = $(Get-Random -InputObject $allVideos).FullName
        Write-Host "Picked to play $pickedPhoto" -ForegroundColor Yellow
        Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe" -PassThru "--start-time 5 `"$pickedPhoto`" --fullscreen"
        Start-Sleep -Seconds 4
    }
}

