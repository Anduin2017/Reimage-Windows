function Get-LatestKubectlVersion {
    $url = "https://storage.googleapis.com/kubernetes-release/release/stable.txt"
    $latestVersion = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
    return $latestVersion.Trim()
}


function InstallKubectl {
    Write-Host "Downloading Kubernetes CLI..." -ForegroundColor Green
    $toolsPath = "${env:ProgramFiles}\Kubernetes"
    $version = Get-LatestKubectlVersion
    $downloadUri = "https://dl.k8s.io/release/$version/bin/windows/amd64/kubectl.exe"
    
    $downloadedTool = $env:USERPROFILE + "\kubectl.exe"
    Remove-Item $downloadedTool -ErrorAction SilentlyContinue
    aria2c.exe $downloadUri -d $HOME -o "kubectl.exe" --check-certificate=false
    
    New-Item -Type Directory -Path "${env:ProgramFiles}\Kubernetes" -ErrorAction SilentlyContinue
    Move-Item $downloadedTool "$toolsPath\kubectl.exe" -Force
    AddToPath -folder $toolsPath
}

Export-ModuleMember -Function InstallKubectl