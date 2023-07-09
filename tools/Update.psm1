function Invoke-ComputerInitialization {
    # This will start a new PowerShell window outside Windows terminal with Admin permission.
    Start-Process "PowerShell.exe" -PassThru "Invoke-ComputerInitializationInCurrentSession" -Verb RunAs
}

function Invoke-ComputerInitializationInCurrentSession {
    # This will run this update script inside current terminal.
    Remove-Item "$env:TEMP\reimage-windows-master\" -Recurse -ErrorAction SilentlyContinue
    $destinationPath = "$env:TEMP\reimage-windows-master.zip"
    Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/archive/master/reimage-windows-master.zip" -OutFile $destinationPath
    Expand-Archive -Path $destinationPath -DestinationPath $env:TEMP
    Remove-Item $destinationPath
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
    . "$env:TEMP\reimage-windows-master\install.ps1"
}

Export-ModuleMember -Function Invoke-ComputerInitialization
Export-ModuleMember -Function Invoke-ComputerInitializationInCurrentSession