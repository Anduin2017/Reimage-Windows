function GetUserEmail {
    $gitPath = Get-Command git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if ($gitPath) {
        $email = (git config --global user.email).Trim()
        if ($email -eq "") {
            $email = Read-Host "Please enter your email address"
        }
    }
    else {
        $email = Read-Host "Git is not installed. Please enter your email address"
    }
    return $email
}

Export-ModuleMember -Function GetUserEmail