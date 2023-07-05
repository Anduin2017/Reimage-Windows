Import-Module .\tools\CloneReposToPath.psm1

function DownloadMyRepos() {

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

    $groupUrl = "$apiUrl/groups?search=$groupName"
    $groupRequest = Invoke-RestMethod -Uri $groupUrl
    $groupId = $groupRequest[0].id
    $repoUrlAiursoft = "$apiUrl/groups/$groupId/projects?simple=true&per_page=100"
    $reposAiursoft = Invoke-RestMethod -Uri $repoUrlAiursoft
    CloneReposToPath $reposAiursoft $destinationPathAiursoft
    
    $userUrl = "$apiUrl/users?username=$userName"
    $userRequest = Invoke-RestMethod -Uri $userUrl
    $userId = $userRequest[0].id
    $repoUrlAnduin = "$apiUrl/users/$userId/projects?simple=true&per_page=100"
    $reposAnduin = Invoke-RestMethod -Uri $repoUrlAnduin
    CloneReposToPath $reposAnduin $destinationPathAnduin
}

Export-ModuleMember -Function DownloadMyRepos
