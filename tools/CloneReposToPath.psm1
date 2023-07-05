function CloneReposToPath($repos, $destinationPath) {
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

Export-ModuleMember -Function CloneReposToPath