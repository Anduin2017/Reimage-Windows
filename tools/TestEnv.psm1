function TestEnv {
    $(Invoke-WebRequest "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/test_env.sh").Content | bash
}

Export-ModuleMember -Function TestEnv