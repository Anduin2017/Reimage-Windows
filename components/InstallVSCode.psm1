function InstallVSCode {
    if ("$(winget list --id Microsoft.VisualStudioCode --source winget)".Contains("--")) { 
        Write-Host "Microsoft.VisualStudioCode is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to download Microsoft VS Code..." -ForegroundColor Green
        winget install --exact --id Microsoft.VisualStudioCode --scope Machine --interactive --source winget
        Write-Host "Kill Admin Microsoft VS Code..." -ForegroundColor Gray
        Get-Process -Name Code | Stop-Process
        Write-Host "Start normal user Microsoft VS Code..." -ForegroundColor Gray
        explorer.exe "$env:ProgramFiles\Microsoft VS Code\Code.exe"
    }
}

Export-ModuleMember -Function InstallVSCode