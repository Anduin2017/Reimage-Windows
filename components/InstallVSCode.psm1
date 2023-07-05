function InstallVSCode {
    if ("$(winget list --id Microsoft.VisualStudioCode --source winget)".Contains("--")) { 
        Write-Host "Microsoft.VisualStudioCode is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to download Microsoft VS Code..." -ForegroundColor Green
        winget install --exact --id Microsoft.VisualStudioCode --scope Machine --interactive --source winget
    }
}

Export-ModuleMember -Function InstallVSCode