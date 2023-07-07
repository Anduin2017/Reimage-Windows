
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
        if (($recordedVideos | Where-Object { $_.Name.EndsWith("-$pickedVideoName-.mp4") } | Measure-Object).Count -gt 0) {
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
                Move-Item -Path $pickedVideo -Destination "$destination\$($pickedVideo.Directory.Name)-$($pickedVideoName)"
            }
        }
    }
}

Export-ModuleMember -Function Watch-RandomVideo