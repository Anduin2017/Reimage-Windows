Write-Host "Installing profile file..." -ForegroundColor Green
if (!(Test-Path $PROFILE))
{
   Write-Host "Creating PROFILE..." -ForegroundColor Yellow
   New-Item -Path $PROFILE -ItemType "file" -Force
}
$profileContent = (New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/PROFILE.ps1')
Set-Content $PROFILE $profileContent
. $PROFILE

Reimage
