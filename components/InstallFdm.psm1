Import-Module "..\tools\Install-IfNotInstalled.psm1"
Import-Module "..\tools\AddToPath.psm1"

function InstallFdm {
    if ("$(winget list -e --id "SoftDeluxe.FreeDownloadManager" --source winget)".Contains("--")) { 
        Write-Host "SoftDeluxe.FreeDownloadManager is already installed!" -ForegroundColor Green

        Write-Host "Clean up FDM..."
        Get-Process -Name fdm -ErrorAction SilentlyContinue | Stop-Process
        Remove-Item -Path "$env:LOCALAPPDATA\Softdeluxe" -Force -Recurse -ErrorAction SilentlyContinue
    }
    else {
        $url = "https://files2.freedownloadmanager.org/6/latest/fdm_x64_setup.exe"
        $output = "$env:USERPROFILE\fdm_x64_setup.exe"
        Invoke-WebRequest -Uri $url -OutFile $output
        Start-Process -FilePath $output -ArgumentList "/VERYSILENT" -Wait
    }

    Write-Host "Start new FDM and kill it..."
    Start-Process "$env:ProgramFiles\Softdeluxe\Free Download Manager\fdm.exe"
    Start-Sleep -Seconds 5
    Get-Process -Name fdm | Stop-Process

    Write-Host "Replace FDM config files..."
    $fdmDbPath = "$env:LOCALAPPDATA\Softdeluxe\Free Download Manager\db.sqlite"
    Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/db.sqlite?inline=false" -OutFile "$fdmDbPath"

    Write-Host "Avoid FDM auto start..."
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Free Download Manager" -Force
}

Export-ModuleMember -Function InstallFdm
