function Check-Env {
    $(Invoke-WebRequest https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/test_env.sh -UseBasicParsing).Content | bash
}

Export-ModuleMember -Function Check-Env