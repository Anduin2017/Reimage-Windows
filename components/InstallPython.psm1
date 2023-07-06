Import-Module "..\tools\Install-IfNotInstalled.psm1"

function RemovePython {
    Write-Host "Removing python..." -ForegroundColor Green
    if (Get-Command -ErrorAction SilentlyContinue "python.exe") {
        Write-Host "Python is found! Removing Python..."
        winget uninstall  "Python Launcher"
        winget uninstall Python.Python.3.10
        Write-Host "Removing existing python..." -ForegroundColor Green
        Remove-Item -Path "C:\Users\AnduinXue\AppData\Local\Microsoft\WindowsApps\python.exe" -Recurse -Force -ErrorAction SilentlyContinue
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

        Remove-Item (Get-Command python).Source -Force -ErrorAction SilentlyContinue
    }
}

function CleanPython {
    $pyPath = $(where.exe python)
    $isClean = $pyPath -match "WindowsApps"
    if ($isClean) {
        Write-Host "Python is clean!" -ForegroundColor Green
    } else {
        Write-Host "Python is not clean! Cleaning it..." -ForegroundColor Green
        RemovePython
    }
}

function InstallPython {
    CleanPython
    Install-IfNotInstalled "Python.Python.3.10"
}

Export-ModuleMember -Function InstallPython