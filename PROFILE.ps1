# PROFILE FILE

# Basic modules
$modules = Get-ChildItem -Path "$PSScriptRoot\Tools\"  -Recurse -Filter *.psm1
$modules.FullName | ForEach-Object { Import-Module $_ -DisableNameChecking }

# Easier to use
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

# Aliases
Import-Module 'C:\Program Files\gsudo\Current\gsudoModule.psd1'
Set-Alias 'sudo' 'gsudo'

Write-Host "Welcome, Anduin! Enjoy your personal Windows!" -ForegroundColor DarkMagenta
Invoke-PromptUpdateLocalProfile
