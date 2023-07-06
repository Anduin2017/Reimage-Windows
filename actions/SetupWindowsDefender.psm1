

function SetupWindowsDefender {
    Write-Host "Exclude repos from Windows Defender..." -ForegroundColor Green
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\source\repos"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\.nuget"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\.dotnet"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\.azuredatastudio"
    Add-MpPreference -ExclusionPath "$env:APPDATA\npm"
    Add-MpPreference -ExclusionPath "$env:USERPROFILE\Nextcloud"
}

Export-ModuleMember -Function SetupWindowsDefender