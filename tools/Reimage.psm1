function Reimage {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/Reimage.ps1'))
}

Export-ModuleMember -Function Reimage