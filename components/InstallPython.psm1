Import-Module "..\tools\Install-IfNotInstalled.psm1"

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
}

function CleanPython {
    $pyPath = $(where.exe python)
    $isClean = $pyPath -notmatch "WindowsApps"
    if ($null -eq $pyPath) {
        $isClean = $false
    }
    if ($isClean) {
        Write-Host "Python is clean!" -ForegroundColor Green
    } else {
        Write-Host "Python is not clean or not found! Cleaning it..." -ForegroundColor Red
        RemovePython
    }
}

function InstallPython {
    CleanPython
    Install-IfNotInstalled "Python.Python.3.10"
}

Export-ModuleMember -Function InstallPython