function Update-All {
    # This will start a new PowerShell window outside Windows terminal with Admin permission.
    Start-Process "PowerShell.exe" -PassThru "Force-UpdateAll" -Verb RunAs
}

function Force-UpdateAll {
    # This will run this update script inside current terminal.
    Remove-Item "$env:TEMP\reimage-windows-master\" -Recurse -ErrorAction SilentlyContinue
    $destinationPath = "$env:TEMP\reimage-windows-master.zip"
    Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/archive/master/reimage-windows-master.zip" -OutFile $destinationPath
    Expand-Archive -Path $destinationPath -DestinationPath $env:TEMP
    Remove-Item $destinationPath
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
    . "$env:TEMP\reimage-windows-master\install_v2.ps1"
}

Export-ModuleMember -Function ReloadPath
Export-ModuleMember -Function AddToPath