Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\tools\Qget.psm1" | Resolve-Path)


function InstallFdm {
    if ("$(winget list -e --id "SoftDeluxe.FreeDownloadManager" --source winget)".Contains("--")) { 
        Write-Host "SoftDeluxe.FreeDownloadManager is already installed!" -ForegroundColor Green

        Write-Host "Clean up FDM..."
        Get-Process helperservice -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Get-Process -Name fdm     -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Softdeluxe" -Force -Recurse -ErrorAction SilentlyContinue
    }
    else {
        $url = "https://files2.freedownloadmanager.org/6/latest/fdm_x64_setup.exe"
        $output = "$env:USERPROFILE\fdm_x64_setup.exe"
        Write-Host "Downloading SoftDeluxe.FreeDownloadManager... It may costs around 1 minute." -ForegroundColor Green
        Qget $url $output
        Start-Process -FilePath $output -ArgumentList "/VERYSILENT /ALLUSERS" -Wait
    }

    
    Write-Host "Replace FDM config files..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\Softdeluxe\Free Download Manager" -ErrorAction SilentlyContinue | Out-Null
    $fdmDbPath = "$env:LOCALAPPDATA\Softdeluxe\Free Download Manager\db.sqlite"
    Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/db.sqlite?inline=false" -OutFile "$fdmDbPath"

    Write-Host "Avoid FDM auto start..." -ForegroundColor Yellow
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Free Download Manager" -Force -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function InstallFdm
