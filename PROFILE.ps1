# PROFILE FILE

Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

Import-Module 'C:\Program Files\gsudo\Current\gsudoModule.psd1'
Set-Alias 'sudo' 'gsudo'

function Update-All {
    # This will start a new PowerShell window outside Windows terminal with Admin permission.
    Start-Process "PowerShell.exe" -PassThru "Force-UpdateAll" -Verb RunAs
}

function Check-Env {
    $(Invoke-WebRequest https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/test_env.sh -UseBasicParsing).Content | bash
}

function Force-UpdateAll {
    # This will run this update script inside current terminal.
    Remove-Item "$env:TEMP\reimage-windows-master\" -Recurse -ErrorAction SilentlyContinue
    $destinationPath = "$env:TEMP\reimage-windows-master.zip"
    Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/archive/master/reimage-windows-master.zip" -OutFile $destinationPath
    Expand-Archive -Path $destinationPath -DestinationPath $env:TEMP
    Remove-Item $destinationPath
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
    . "$env:TEMP\reimage-windows-master\install_v2.ps1"
}

function Reimage {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/Reimage.ps1'))
}

function Qget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$address,
        [string]$path = ""
    )

    if ($path -eq "") {
        # 如果没有指定 path，则使用当前目录并保留原有文件名
        $path = ".\$(Split-Path -Leaf $address)"
    }

    $aria2cArgs = "-c -s 128 -x 8 -k 4M -j 128 --split 128 `"$address`" -d `"$([System.IO.Path]::GetDirectoryName($path))`" -o `"$([System.IO.Path]::GetFileName($path))`" --check-certificate=false"
    Invoke-Expression "aria2c.exe $aria2cArgs"
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

function CloneReposToPath($repos, $destinationPath) {
    foreach ($repo in $repos) {
        $repoName = $repo.name
        $repoUrl = $repo.ssh_url_to_repo
        $repoPath = Join-Path $destinationPath $repoName

        if (!(Test-Path -Path $repoPath)) {
            git clone $repoUrl $repoPath
            Write-Host "Cloned $repoName to $repoPath"
        }
        else {
            Write-Host "$repoName already exists at $repoPath, skipping."
        }
    }
}

function ResetRepos {
    Write-Host "Deleting items..."
    Remove-Item "$HOME\source\repos\Aiursoft\" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$HOME\source\repos\Anduin\" -Recurse  -Force -ErrorAction SilentlyContinue
    Write-Host "Items deleted!"
    
    Start-Sleep -Seconds 5
    
    Write-Host "Clonging all repos..." -ForegroundColor Green
    # 设置变量
    $gitlabBaseUrl = "https://gitlab.aiursoft.cn"
    $apiUrl = "$gitlabBaseUrl/api/v4"
    $groupName = "Aiursoft"
    $userName = "Anduin"
    
    $destinationPathAiursoft = "$HOME\source\repos\Aiursoft"
    $destinationPathAnduin = "$HOME\source\repos\Anduin"
    
    # 创建目标文件夹
    if (!(Test-Path -Path $destinationPathAiursoft)) {
        New-Item -ItemType Directory -Path $destinationPathAiursoft | Out-Null
    }
    if (!(Test-Path -Path $destinationPathAnduin)) {
        New-Item -ItemType Directory -Path $destinationPathAnduin | Out-Null
    }
    
    # 获取组织ID
    $groupUrl = "$apiUrl/groups?search=$groupName"
    $groupRequest = Invoke-RestMethod -Uri $groupUrl
    $groupId = $groupRequest[0].id
    
    # 获取用户ID
    $userUrl = "$apiUrl/users?username=$userName"
    $userRequest = Invoke-RestMethod -Uri $userUrl
    $userId = $userRequest[0].id
    
    # 获取仓库列表
    $repoUrlAiursoft = "$apiUrl/groups/$groupId/projects?simple=true&per_page=100"
    $repoUrlAnduin = "$apiUrl/users/$userId/projects?simple=true&per_page=100"
    
    $reposAiursoft = Invoke-RestMethod -Uri $repoUrlAiursoft
    $reposAnduin = Invoke-RestMethod -Uri $repoUrlAnduin
    
    # 克隆仓库
    CloneReposToPath $reposAiursoft $destinationPathAiursoft
    CloneReposToPath $reposAnduin $destinationPathAnduin
}

