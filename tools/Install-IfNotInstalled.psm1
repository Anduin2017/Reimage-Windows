function Install {
    param (
        [string]$package
    )

    $attempt = 0
    do {
        try {
            # Do something that has a high possiblity to crash.
            winget install -e --id $package --source winget

            if (-not $LASTEXITCODE) {
                $success = $true
            }
            else {
                throw "Transient error. LASTEXITCODE is $LASTEXITCODE."
            }
        }
        catch {
            if ($attempt -eq 5) {
                # You can do some extra logging here.
                Write-Error "Task failed. With all $attempt attempts. Error: $($Error[0])"
                throw
            }

            Write-Host "Task failed. Attempt $attempt. Will retry in next $(5 * $attempt) seconds. Error: $($Error[0])" -ForegroundColor Yellow
            Start-Sleep -Seconds $(5 * $attempt)
        }
    
        $attempt++
    
    } until($success)
    
}

function Install-IfNotInstalled {
    param (
        [string]$package
    )

    if ("$(winget list -e --id $package --source winget)".Contains("--")) { 
        Write-Host "$package is already installed!" -ForegroundColor Green
    }
    else {
        Write-Host "Attempting to install: $package..." -ForegroundColor Green
        Install $package
    }
}

Export-ModuleMember -Function Install-IfNotInstalled