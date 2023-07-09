Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\actions\Install-IfNotInstalled.psm1" | Resolve-Path)


function RemovePython {
    Write-Host "Removing dirty MS fake python..." -ForegroundColor Yellow
    winget uninstall  "Python Launcher"
    winget uninstall Python.Python.3.10
    Write-Host "Removing existing python..." -ForegroundColor Green
    Remove-Item -Path "$env:APPDATA\Python\" -Recurse -Force -ErrorAction SilentlyContinue
    $currentPath = [Environment]::GetEnvironmentVariable("PATH")
    $pathDirs = $currentPath -split ";"
    $pythonDirs = $pathDirs | Where-Object { $_ -like "*python*" }
    Write-Host "Removing existing path $pythonDirs..." -ForegroundColor Green
    $pythonDirs | ForEach-Object { $currentPath = $currentPath.Replace($_ + ";", "") }
    [Environment]::SetEnvironmentVariable("PATH", $currentPath, "Machine")
    $searchFolder = 'C:\Program Files'
    $folders = Get-ChildItem -Path $searchFolder -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*python*" }
    foreach ($folder in $folders) {
        Write-Host "Removing existing folder $($folder.FullName)..." -ForegroundColor Green
        Remove-Item $folder.FullName -Recurse -ErrorAction SilentlyContinue
    }
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Remove-Item (Get-Command python -ErrorAction SilentlyContinue).Source -Force -ErrorAction SilentlyContinue
    }

    Remove-Item "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe"  -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Microsoft\WindowsApps\python3.exe" -ErrorAction SilentlyContinue
}

function CleanPython {
    $pyPath = $(where.exe python)
    $isDirty = $pyPath -match "WindowsApps"
    if ($null -eq $pyPath) {
        $isDirty = $true
    }
    if ($isDirty) {
        Write-Host "Python is not clean or not found! Cleaning it..." -ForegroundColor Red
        Write-Host "Python is $pyPath" -ForegroundColor Yellow
        RemovePython
    } else {
        Write-Host "Python is clean!" -ForegroundColor Green
    }
}

function InstallPython {
    CleanPython
    Install-IfNotInstalled "Python.Python.3.10"
}

Export-ModuleMember -Function InstallPython