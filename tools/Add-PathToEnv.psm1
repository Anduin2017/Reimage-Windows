function ReloadPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Update-PathVariable {
    param (
        [string]$variableScope = "Machine",
        [switch]$verbose
    )

    # Get the current PATH environment variable
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", $variableScope)

    # Split the PATH string into an array of directories
    $directories = $currentPath -split ';'

    # Initialize an empty array to store updated directories
    $updatedDirectories = @()

    foreach ($directory in $directories) {
        # Check if the directory exists
        if (Test-Path -Path $directory -PathType Container) {
            # If the directory exists, add it to the updated directories array
            $updatedDirectories += $directory
        } elseif ($verbose) {
            # If the directory doesn't exist and verbose output is enabled, print the directory to be removed
            Write-Host "Removing non-existent directory from PATH: $directory"
        }
    }

    # Join the updated directories back into a single PATH string
    $newPath = $updatedDirectories -join ';'

    # Check if the new PATH value is different from the original value
    if ($newPath -eq $currentPath) {
        if ($verbose) {
            Write-Host "No changes needed to the $variableScope PATH variable."
        }
        return
    }

    try {
        # Set the new PATH environment variable
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $variableScope)

        if ($verbose) {
            # Print the updated PATH variable
            Write-Host "Updated $variableScope PATH: $($newPath)"
        }

        # Update the current session's PATH environment variable
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    } catch {
        Write-Host "Error: Failed to update the $variableScope PATH variable. Please ensure you have the necessary permissions."
    }
}

function Add-PathToEnv {
    param (
        [string]$folder
    )

    Write-Host "Adding $folder to environment variables..." -ForegroundColor Yellow

    $currentEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine).Trim(";");
    $addedEnv = $currentEnv + ";$folder"
    $trimmedEnv = (($addedEnv.Split(';') | Select-Object -Unique) -join ";").Trim(";")
    [Environment]::SetEnvironmentVariable(
        "Path",
        $trimmedEnv,
        [EnvironmentVariableTarget]::Machine)

    Update-PathVariable
    ReloadPath
}

Export-ModuleMember -Function ReloadPath
Export-ModuleMember -Function Add-PathToEnv
Export-ModuleMember -Function Update-PathVariable
