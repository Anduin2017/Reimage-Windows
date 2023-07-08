function InstallNFSClient {
    Write-Host "Installing NFS client..." -ForegroundColor Green
    Enable-WindowsOptionalFeature -FeatureName ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart
}

Export-ModuleMember -Function InstallNFSClient