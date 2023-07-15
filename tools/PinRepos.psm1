function PinRepos {
    Write-Host "Pin repos to quick access..." -ForegroundColor Green
    $load_com = new-object -com shell.application
    $load_com.Namespace("$env:USERPROFILE\source\repos").Self.InvokeVerb("pintohome")
    Write-Host "Repos folder are pinned to file explorer."
}

Export-ModuleMember -Function PinRepos