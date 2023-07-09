# PROFILE FILE

# Basic modules
$modulePath = "$HOME\source\repos\Anduin\Reimage-Windows\tools\"
$modules = Get-ChildItem -Path $modulePath -Filter *.psm1
foreach ($module in $modules) {
    Import-Module $module.FullName -DisableNameChecking
}

# Easier to use
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

# Aliases
Import-Module 'C:\Program Files\gsudo\Current\gsudoModule.psd1'
Set-Alias 'sudo' 'gsudo'

Write-Host "Welcome, Anduin! Enjoy your personal Windows!" -ForegroundColor DarkMagenta
Invoke-PromptUpdateLocalProfile
