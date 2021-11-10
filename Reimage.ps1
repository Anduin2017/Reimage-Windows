function Get-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    { Write-Output $true }      
    else
    { Write-Output $false }   
}
    
function Reimage {
    if (-not(Get-IsElevated)) { 
        throw "Please run this script as an administrator" 
    }

    # Get disk
    Write-Host "Please provide me a clean disk amount point. Example: 'Q': " -ForegroundColor Yellow
    $diskMount = $(Read-Host).Trim(':')

    # Ensure disk exists
    if (Test-Path -Path "$($diskMount):\") {
        Write-Host "Disk $diskMount exists!" -ForegroundColor Green
    } else {
        Write-Host "Disk $diskMount doesn't exist!" -ForegroundColor Red
        return
    }

    # Ensure disk enough size
    if ((Get-Volume $diskMount).Size -lt 53687087104) {
        Write-Host "Disk $diskMount too mall! Please assign at least 50GB!" -ForegroundColor Red
        return
    }

    # Format to NTFS.
    Get-ChildItem "$($diskMount):\" -ErrorAction SilentlyContinue
    Write-Host "Enter 'Y' if you want to format disk $diskMount [Y or N]:" -ForegroundColor Yellow
    $format = Read-Host
    if ($format -eq "Y") {
        Format-Volume -DriveLetter $diskMount -FileSystem NTFS 
    } else {
        return
    }

    # Disable Bitlocker
    Disable-BitLocker -MountPoint $diskMount

    # Enlist ISO options
    Write-Host "All ISO files here: " -ForegroundColor Yellow
    Get-ChildItem -Filter "*.iso" | Format-Table -AutoSize
    Write-Host "Download Windows 10: https://www.microsoft.com/en-US/software-download/windows10" -ForegroundColor DarkBlue
    Write-Host "Download Windows 11: https://www.microsoft.com/en-us/software-download/windows11" -ForegroundColor DarkBlue
    Write-Host "Download Windows Insider: https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewiso" -ForegroundColor DarkBlue

    Write-Host "Enter the downloaded local ISO file name: " -ForegroundColor Yellow
    $iso = Read-Host
    $iso = (Resolve-Path $iso).Path
    if (Test-Path -Path "$iso") {
        Get-Item "$iso" | Format-List
        Write-Host "ISO $iso exists!" -ForegroundColor Green
    } else {
        Write-Host "ISO $iso doesn't exist!" -ForegroundColor Red
        return
    }

    # Mount ISO
    $mounted = Mount-DiskImage -ImagePath $iso -Access ReadOnly -StorageType ISO
    $mountedISO = Get-Volume -DiskImage $mounted
    Write-Host "Mounted:" -ForegroundColor Green
    $mountedISO | Format-List
    $mountedLetter = $mountedISO.DriveLetter
    Write-Host "Files inside:" -ForegroundColor Green
    Get-ChildItem "$($mountedLetter):" | Format-Table -AutoSize

    # Get OS Index
    dism /Get-ImageInfo /imagefile:"$($mountedLetter):\sources\install.wim"
    Write-Host "Please provide the OS Index number. Example: '6': " -ForegroundColor Yellow
    $osIndex = Read-Host

    # Get OS Name
    Write-Host "Please name the new OS. Example: Windows VNext: " -ForegroundColor Yellow
    $osName = Read-Host

    Write-Host "Extracting OS..." -ForegroundColor Green
    dism /apply-image /imagefile:"$($mountedLetter):\sources\install.wim" /index:"$osIndex" /ApplyDir:"$($diskMount):\"

    # Dismount ISO
    Write-Host "Dismounting the iso..." -ForegroundColor Green
    Dismount-DiskImage $iso

    # Create start up registry.
    $created = bcdedit /create /d "$osName" /application osloader
    $osID = $created | Select-String -Pattern '{[-0-9A-F]+?}' -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value
    bcdedit /set "$osID" device "partition=$($diskMount):"
    bcdedit /set "$osID" path "\WINDOWS\system32\winload.efi"
    bcdedit /set "$osID" systemroot "\WINDOWS"
    bcdedit /set "$osID" osdevice "partition=$($diskMount):"
    bcdedit /set "$osID" locale "en-US"
    bcdedit /set "$osID" inherit "{bootloadersettings}"
    bcdedit /set "$osID" nx "OptIn"
    bcdedit /set "$osID" bootmenupolicy "Standard"
    bcdedit /set "$osID" displaymessageoverride "Recovery"
    bcdedit /set "$osID" recoveryenabled "Yes"
    bcdedit /set "$osID" isolatedcontext "Yes"
    bcdedit /set "$osID" flightsigning "Yes"
    bcdedit /set "$osID" allowedinmemorysettings "0x15000075"
    bcdedit /displayorder "$osID" /addlast
    bcdedit /set "{bootmgr}" default "$osID"
    Write-Host "Modified boot configuration:" -ForegroundColor Green
    bcdedit

    # Disable Bitlocker
    Disable-BitLocker -MountPoint $diskMount
    
    Write-Host "Unmounting hard disk..." -ForegroundColor Green
    mountvol "$($diskMount):" /P

    Write-Host "Job finished! Pending reboot!" -ForegroundColor Green
    Write-Host "Press Enter to reboot now..." -ForegroundColor Yellow
    Read-Host
    
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}

Reimage
