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

    # Get a drive, get the WIM file.
    $systemDrive = (Get-WmiObject Win32_OperatingSystem).SystemDrive.Trim(':')
    # Get disk
    Write-Host "Please provide me a clean disk amount point. Example: 'Q': " -ForegroundColor Yellow
    $diskMount = $(Read-Host).Trim(':')

    # Ensure disk exists
    if (Test-Path -Path "$($diskMount):\") {
        Write-Host "Disk $diskMount exists!" -ForegroundColor Green
    } else {
        throw "Disk $diskMount doesn't exist!"
    }

    if ($systemDrive.ToLower() -eq $diskMount.ToLower()) {
        throw "You can't install new OS on your existing OS drive: $diskMount!"
    }

    # Ensure disk enough size
    if ((Get-Volume $diskMount).Size -lt 20000000000) {
        throw "Disk $diskMount too mall! Please assign at least 20GB!"
    }

    # Format to NTFS.
    Get-ChildItem "$($diskMount):\" -ErrorAction SilentlyContinue
    Write-Host "Enter 'Y' if you want to format disk $diskMount [Y or N]:" -ForegroundColor Yellow
    $format = Read-Host
    if ($format -eq "Y") {
        Format-Volume -DriveLetter $diskMount -FileSystem NTFS 
    } else {
        throw "You must format that disk first!"
    }

    # Disable Bitlocker
    Disable-BitLocker -MountPoint $diskMount
    
    do {
        Write-Host "We need the Windows image file. What do you have now?`n" -ForegroundColor Yellow
        Write-Host -NoNewline "A: " -ForegroundColor White
        Write-Host "I have nothing. Help me download the new OS."
        Write-Host -NoNewline "B: " -ForegroundColor White
        Write-Host "I have nothing. Tell me how to download the new OS. (I will manually download it)"
        Write-Host -NoNewline "C: " -ForegroundColor White
        Write-Host "I already have the ISO file downloaded locally."
        Write-Host -NoNewline "D: " -ForegroundColor White
        Write-Host "I already have the install.wim file locally.`n"

        $userOption = Read-Host -Prompt 'Select'
        if($userOption.Length -eq 1 -and $userOption.ToLower() -ge "a" -and $userOption.ToLower() -le "d") {
            break
        } else {
            Write-Host "Invalid input!" -ForegroundColor Red
        }
    } until($false)

    if ($userOption.ToLower() -eq "a") {
        Start-Process powershell {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://githubcontent.aiurs.co/pbatard/Fido/master/Fido.ps1'))
        }

        Read-Host "Press [Enter] if you finished downloading the ISO file."
    } 
    
    if ($userOption.ToLower() -eq "b") {
        Write-Host "Please open the following link to download Windows ISO:`n" -ForegroundColor Yellow
        Write-Host -NoNewline "Download Windows 10: " -ForegroundColor White
        Write-Host "https://www.microsoft.com/en-US/software-download/windows10" -ForegroundColor DarkBlue
        Write-Host -NoNewline "Download Windows 11: " -ForegroundColor White
        Write-Host "https://www.microsoft.com/en-us/software-download/windows11" -ForegroundColor DarkBlue
        Write-Host -NoNewline "Download Windows Insider: " -ForegroundColor White
        Write-Host "Download Windows Insider: https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewiso" -ForegroundColor DarkBlue
        
        Read-Host "Press [Enter] if you finished downloading the ISO file."
    }

    if ($userOption.ToLower() -eq "a" -or $userOption.ToLower() -eq "b" -or $userOption.ToLower() -eq "c") {
        # Enlist ISO options
        Write-Host "All ISO files here ($($(Get-Location))): " -ForegroundColor White
        Get-ChildItem -Filter "*.iso" | Format-Table -AutoSize

        Write-Host "`nPlease provide me the path of your ISO file (ends with .iso):" -ForegroundColor Yellow

        $iso = Read-Host
        $iso = (Resolve-Path $iso).Path
        if (Test-Path -Path "$iso") {
            Get-Item "$iso" | Format-List
            Write-Host "ISO $iso exists!" -ForegroundColor Green
        } else {
            throw "ISO $iso doesn't exist! Please check your path!"
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
        $wimFile = "$($mountedLetter):\sources\install.wim"
    }

    if ($userOption.ToLower() -eq "d") {
        # Enlist ISO options
        Write-Host "All WIM files here ($($(Get-Location))): " -ForegroundColor White
        Get-ChildItem -Filter "*.wim" | Format-Table -AutoSize

        Write-Host "`nPlease provide me the path of your WIM file:" -ForegroundColor Yellow

        $wim = Read-Host
        $wim = (Resolve-Path $wim).Path
        if (Test-Path -Path "$wim") {
            Get-Item "$wim" | Format-List
            Write-Host "WIM $wim exists!" -ForegroundColor Green
        } else {
            throw "WIM $wim doesn't exist!"
        }

        $wimFile = $wim
    }

    dism /Get-ImageInfo /imagefile:"$wimFile"
    Write-Host "Please provide the OS Index number. Example: '6': " -ForegroundColor Yellow
    $osIndex = Read-Host

    # Get OS Name
    Write-Host "Please name the new OS. Example: Windows VNext: " -ForegroundColor Yellow
    $osName = Read-Host

    Write-Host "Extracting OS..." -ForegroundColor Green
    dism /apply-image /imagefile:"$wimFile" /index:"$osIndex" /ApplyDir:"$($diskMount):\"

    # Dismount ISO
    if ($iso) {
        Write-Host "Dismounting the iso..." -ForegroundColor Green
        Dismount-DiskImage $iso -ErrorAction SilentlyContinue
    }

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
    
    Restart-Computer -Force
}

Reimage
