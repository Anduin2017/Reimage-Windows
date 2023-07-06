function InstallVSCode {
    if ("$(winget list --id Microsoft.VisualStudioCode --source winget)".Contains("--")) { 
        Write-Host "Microsoft.VisualStudioCode is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to download Microsoft VS Code..." -ForegroundColor Green
        winget install --exact --id Microsoft.VisualStudioCode --scope Machine --source winget

        New-Item -Path "HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode" -Force | Out-Null
        New-Item -Path "HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode\command" -Force | Out-Null
        New-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode" -Name "Icon" -Value "C:\Program Files\Microsoft VS Code\Code.exe" -Force | Out-Null
        New-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode" -Name "MUIVerb" -Value "Open with VSCode" -Force | Out-Null
        New-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Directory\Background\shell\VSCode\command" -Name "(Default)" -Value """C:\Program Files\Microsoft VS Code\Code.exe"" ""%V""" -Force | Out-Null
    }
}

Export-ModuleMember -Function InstallVSCode