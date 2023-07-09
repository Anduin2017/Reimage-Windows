
function Clone-GitRepositories($repos, $destinationPath) {
    foreach ($repo in $repos) {
        $repoName = $repo.name
        $repoUrl = $repo.ssh_url_to_repo
        $repoPath = Join-Path $destinationPath $repoName

        if (!(Test-Path -Path $repoPath)) {
            git clone $repoUrl $repoPath
            Write-Host "Cloned $repoName to $repoPath"
        } else {
            Write-Host "$repoName already exists at $repoPath, skipping."
        }
    }
}

Export-ModuleMember -Function Clone-GitRepositories
function Reset-GitRepos {
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
    Clone-GitRepositories $reposAiursoft $destinationPathAiursoft
    Clone-GitRepositories $reposAnduin $destinationPathAnduin
}

Export-ModuleMember -Function Reset-GitRepos
Export-ModuleMember -Function Clone-GitRepositories