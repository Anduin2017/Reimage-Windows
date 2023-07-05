function UpdateStoreApps {
    Write-Host "Updating Store...(ETA: 10 seconds...)..." -ForegroundColor Green
    $namespaceName = "root\cimv2\mdm\dmmap"
    $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
    $wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
    $wmiObj.UpdateScanMethod() | Out-Null
}

Export-ModuleMember -Function UpdateStoreApps