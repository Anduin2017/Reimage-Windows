function Get-LatestProfileVersion {
    param (
    )
    $url = "https://gitlab.aiursoft.cn/api/v4/projects/anduin%2Freimage-windows/repository/commits"
    $response = Invoke-RestMethod -Uri $url -Method Get
    $latestCommit = $response[0]
    return $latestCommit.created_at
}

function Get-CurrentProfileVersion {
    # Get Version (Date time from file)
    $markerLocation = "$env:USERPROFILE\.profile-version"
    if (Test-Path $markerLocation) {
        $currentVersion = Get-Content $markerLocation
        return $currentVersion
    } else {
        return $null
    }
}

function Set-CurrentProfileVersion {
    $markerLocation = "$env:USERPROFILE\.profile-version"
    # Set current time to file
    $currentVersion = Get-Date
    $currentVersionString = $currentVersion.ToString("yyyy-MM-dd HH:mm:ss")
    $currentVersionString | Out-File $markerLocation
    Write-Host "Profile version updated to $currentVersionString" -ForegroundColor Green
}

function Prompt-UpdateLocalProfile {
    $currentVersion = Get-CurrentProfileVersion
    $latestVersion = Get-LatestProfileVersion
    # if Current Version is less than latest version:
    if ($currentVersion -lt $latestVersion) {
        Write-Host "Your profile is out of date. Please update it." -ForegroundColor Red
    }
}

Export-ModuleMember -Function Get-LatestProfileVersion
Export-ModuleMember -Function Get-CurrentProfileVersion
Export-ModuleMember -Function Set-CurrentProfileVersion
Export-ModuleMember -Function Prompt-UpdateLocalProfile