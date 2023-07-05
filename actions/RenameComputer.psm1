function RenameComputer {
    $computerName = Read-Host "Enter New Computer Name if you want to rename it: ($($env:COMPUTERNAME))"
    if (-not ([string]::IsNullOrEmpty($computerName))) {
        Write-Host "Renaming computer to $computerName..." -ForegroundColor Green
        cmd /c "bcdedit /set {current} description `"$computerName`""
        Rename-Computer -NewName $computerName
    }
}

Export-ModuleMember -Function RenameComputer