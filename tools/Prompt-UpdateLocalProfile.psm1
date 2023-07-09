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
        return "1970-01-01 00:00:00"
    }
}

function Set-CurrentProfileVersion {
    $markerLocation = "$env:USERPROFILE\.profile-version"
    # Set current time to file
    $currentVersion = Get-Date
    $currentVersionString = $currentVersion.ToString("yyyy-MM-dd HH:mm:ss")
    Set-Content -Value $currentVersionString -Path $markerLocation
    Write-Host "Profile version updated to $currentVersionString" -ForegroundColor Green
}

function Prompt-UpdateLocalProfile {
    $cv = Get-CurrentProfileVersion
    $currentVersion = [datetime]::Parse($cv);
    $lv = Get-LatestProfileVersion
    $latestVersion = [datetime]::Parse($lv);

    # if Current Version is less than latest version:
    if ($currentVersion -lt $latestVersion) {
        Write-Host "Your profile is out of date." -ForegroundColor Red
        Write-Host "Latest version: $latestVersion. Current version: $currentVersion." -ForegroundColor Yellow
    }

    # If Current Version is one month ago
    $oneMonthAgo = (Get-Date).AddMonths(-1)
    if ($currentVersion -lt $oneMonthAgo) {
        Write-Host "UpdateAll hasn't been run for a month!" -ForegroundColor Red
    }
}

Export-ModuleMember -Function Get-LatestProfileVersion
Export-ModuleMember -Function Get-CurrentProfileVersion
Export-ModuleMember -Function Set-CurrentProfileVersion
Export-ModuleMember -Function Prompt-UpdateLocalProfile