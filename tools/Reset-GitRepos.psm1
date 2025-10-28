Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\PinRepos.psm1" | Resolve-Path) -DisableNameChecking

function Clone-GitRepositories($repos, $destinationPath) {
    foreach ($repo in $repos) {
        # 跳过被 archive 的仓库
        if ($repo.archived -eq $true) {
            Write-Host "Skipping archived repository: $($repo.name)"
            continue
        }

        $repoName = $repo.name
        $repoUrl = $repo.ssh_url_to_repo

        # 判断 topics 是否存在且有内容，取出第一个 topic；否则使用 "no-topic"
        if ($repo.topics -and $repo.topics.Count -gt 0) {
            $firstTopic = $repo.topics[0]
        } else {
            $firstTopic = "no-topic"
        }
        
        # 构造最终的 clone 目标路径：$destinationPath\{firstTopic}\{repoName}
        $topicPath = Join-Path $destinationPath $firstTopic
        if (!(Test-Path -Path $topicPath)) {
            New-Item -ItemType Directory -Path $topicPath | Out-Null
        }
        $repoPath = Join-Path $topicPath $repoName
        
        if (!(Test-Path -Path $repoPath)) {
            git clone $repoUrl $repoPath
            Write-Host "Cloned $repoName to $repoPath"
        } else {
            Write-Host "$repoName already exists at $repoPath, skipping."
        }
    }
}

function Reset-GitRepos {
    Write-Host "Deleting items..."
    Remove-Item "$HOME\Source\Repos\Aiursoft\" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$HOME\Source\Repos\Anduin\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Items deleted!"
    
    Start-Sleep -Seconds 5
    
    Write-Host "Cloning all repos..." -ForegroundColor Green
    $gitlabBaseUrl = "https://gitlab.aiursoft.com"
    $apiUrl = "$gitlabBaseUrl/api/v4"
    $groupName = "Aiursoft"
    $userName = "Anduin"
    
    $destinationPathAiursoft = "$HOME\Source\Repos\Aiursoft"
    $destinationPathAnduin = "$HOME\Source\Repos\Anduin"
    
    if (!(Test-Path -Path $destinationPathAiursoft)) {
        New-Item -ItemType Directory -Path $destinationPathAiursoft | Out-Null
    }
    if (!(Test-Path -Path $destinationPathAnduin)) {
        New-Item -ItemType Directory -Path $destinationPathAnduin | Out-Null
    }
    
    $groupUrl = "$apiUrl/groups?search=$groupName"
    $groupRequest = Invoke-RestMethod -Uri $groupUrl
    $groupId = $groupRequest[0].id
    
    $userUrl = "$apiUrl/users?username=$userName"
    $userRequest = Invoke-RestMethod -Uri $userUrl
    $userId = $userRequest[0].id
    
    $repoUrlAiursoft = "$apiUrl/groups/$groupId/projects?simple=true&per_page=999&visibility=public&page=1"
    $repoUrlAnduin = "$apiUrl/users/$userId/projects?simple=true&per_page=999&visibility=public&page=1"
    
    $reposAiursoft = Invoke-RestMethod -Uri $repoUrlAiursoft | Where-Object { $_.archived -ne $true }
    $reposAnduin = Invoke-RestMethod -Uri $repoUrlAnduin | Where-Object { $_.archived -ne $true }
    
    Clone-GitRepositories $reposAiursoft $destinationPathAiursoft
    Clone-GitRepositories $reposAnduin $destinationPathAnduin
}


Export-ModuleMember -Function Reset-GitRepos
Export-ModuleMember -Function Clone-GitRepositories