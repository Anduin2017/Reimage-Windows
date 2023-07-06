function SetupIME {
    Write-Host "Enabling Chinese input method..." -ForegroundColor Green
    Start-Process powershell {
        $UserLanguageList = New-WinUserLanguageList -Language en-US
        $UserLanguageList.Add("zh-CN")
        Set-WinUserLanguageList $UserLanguageList -Force
        $UserLanguageList | Format-Table -AutoSize
    }
}

Export-ModuleMember -Function SetupIME
