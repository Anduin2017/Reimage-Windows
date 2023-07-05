
Import-Module "..\tools\Install-IfNotInstalled.psm1"

function InstallDotnet {
    Install-IfNotInstalled "Microsoft.DotNet.SDK.6"

    Write-Host "Setting up .NET environment variables..." -ForegroundColor Green
    [Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")
    [Environment]::SetEnvironmentVariable("DOTNET_PRINT_TELEMETRY_MESSAGE", "false", "Machine")
    [Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")

    if (-not (Test-Path -Path "$env:APPDATA\Nuget\Nuget.config") -or $null -eq (Select-String -Path "$env:APPDATA\Nuget\Nuget.config" -Pattern "nuget.org")) {
        $config = "<?xml version=`"1.0`" encoding=`"utf-8`"?>`
    <configuration>`
      <packageSources>`
        <add key=`"aiursoft.cn`" value=`"https://nuget.aiursoft.cn/v3/index.json`" protocolVersion=`"3`" />`
        <add key=`"nuget.org`" value=`"https://api.nuget.org/v3/index.json`" protocolVersion=`"3`" />`
        <add key=`"Microsoft Visual Studio Offline Packages`" value=`"C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\`" />`
      </packageSources>`
      <config>`
        <add key=`"repositoryPath`" value=`"D:\CxCache`" />`
      </config>`
    </configuration>"

        $nugetFolderPath = "$env:APPDATA\Nuget"
        if (!(Test-Path $nugetFolderPath)) {
            New-Item -ItemType Directory -Path $nugetFolderPath | Out-Null
        }
        Set-Content -Path "$env:APPDATA\Nuget\Nuget.config" -Value $config
    }
    else {
        Write-Host "Nuget config file already exists." -ForegroundColor Yellow
    }
    New-Item -Path "C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\" -ItemType directory -Force

}

Export-ModuleMember -Function InstallDotnet