function Get-IsElevated {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
    { Write-Output $true }      
    else
    { Write-Output $false }   
}

function EnsureElevated {
    if (-not(Get-IsElevated)) { 
        throw "Please run this script as an administrator" 
    }
    else {
        Write-Host -ForegroundColor DarkGreen "Running as administrator. We can continue."
    }
}

function CheckDmaProtectionStatus {

    # bootDMAProtection check
    $bootDMAProtectionCheck =
    @"
  namespace SystemInfo
    {
      using System;
      using System.Runtime.InteropServices;

      public static class NativeMethods
      {
        internal enum SYSTEM_DMA_GUARD_POLICY_INFORMATION : int
        {
            /// </summary>
            SystemDmaGuardPolicyInformation = 202
        }

        [DllImport("ntdll.dll")]
        internal static extern Int32 NtQuerySystemInformation(
          SYSTEM_DMA_GUARD_POLICY_INFORMATION SystemDmaGuardPolicyInformation,
          IntPtr SystemInformation,
          Int32 SystemInformationLength,
          out Int32 ReturnLength);

        public static byte BootDmaCheck() {
          Int32 result;
          Int32 SystemInformationLength = 1;
          IntPtr SystemInformation = Marshal.AllocHGlobal(SystemInformationLength);
          Int32 ReturnLength;

          result = NativeMethods.NtQuerySystemInformation(
                    NativeMethods.SYSTEM_DMA_GUARD_POLICY_INFORMATION.SystemDmaGuardPolicyInformation,
                    SystemInformation,
                    SystemInformationLength,
                    out ReturnLength);

          if (result == 0) {
            byte info = Marshal.ReadByte(SystemInformation, 0);
            return info;
          }

          return 0;
        }
      }
    }
"@

    if (-not([System.Management.Automation.PSTypeName]'SystemInfo.NativeMethods').Type) {
        Add-Type -TypeDefinition $bootDMAProtectionCheck -Language CSharp -ErrorAction SilentlyContinue
    }

    # returns true or false depending on whether Kernel DMA Protection is on or off
    $bootDMAProtection = ([SystemInfo.NativeMethods]::BootDmaCheck()) -ne 0
    return $bootDMAProtection
}

function CheckVirtualizationBasedSecurityStatus {
    $vbsStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
    
    # 0 = VBS isn't enabled.
    # 1 = VBS is enabled but not running.
    # 2 = VBS is enabled and running.
    return $vbsStatus.VirtualizationBasedSecurityStatus -eq 2
}

function CheckCodeIntegrityPolicyEnforcement {
    $codeIntegrityPolicyEnforcement = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
    
    # 0 = Not Configured.
    # 1 = Audit.
    # 2 = Enforced.
    return $codeIntegrityPolicyEnforcement.CodeIntegrityPolicyEnforcementStatus -eq 2
}

function CheckTpmStatus {
    $tpmStatus = Get-CimInstance -ClassName Win32_Tpm -Namespace root\cimv2\security\microsofttpm
    
    # 0 = The TPM is deactivated or disabled.
    # 1 = The TPM is activated and enabled.
    return $tpmStatus.IsActivated_InitialValue -eq 1 -and $tpmStatus.IsEnabled_InitialValue -eq 1 -and $tpmStatus.IsOwned_InitialValue -eq 1;
}

function CheckSecureBootStatus {
    $secureBootStatus = Confirm-SecureBootUEFI
    $secureBootPk = Get-SecureBootUEFI -Name "PK" -ErrorAction SilentlyContinue

    return $secureBootStatus -and $null -ne $secureBootPk
}

function CheckBitlockerStatus {
    $systemDrive = (Get-WmiObject Win32_OperatingSystem).SystemDrive

    $bitlockerStatus = Get-BitLockerVolume -MountPoint $systemDrive -ErrorAction SilentlyContinue
    return $bitlockerStatus.ProtectionStatus -eq "On"
}

function CheckDeviceEncryptionStatus {
    $systemDrive = (Get-WmiObject Win32_OperatingSystem).SystemDrive

    $deviceEncryptionStatus = Get-CimInstance -ClassName Win32_EncryptableVolume -Namespace root\cimv2\security\microsoftvolumeencryption -Filter "DriveLetter = '$systemDrive'"
    
    # https://learn.microsoft.com/en-us/windows/win32/secprov/win32-encryptablevolume
    return $deviceEncryptionStatus.ProtectionStatus -eq 1 -and $deviceEncryptionStatus.IsVolumeInitializedForProtection -eq $true
}

function CheckWindowsHelloStatus {
    $loggedOnUserSID = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value
    $credentialProvider = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{D6886603-9D2F-4EB2-B667-1971041FA96B}"
    if (Test-Path -Path $credentialProvider) {
        $userSIDs = Get-ChildItem -Path $credentialProvider
        $items = $userSIDs | Foreach-Object { Get-ItemProperty $_.PsPath }
    }
    else {
        return $false
    }
    if (-NOT[string]::IsNullOrEmpty($loggedOnUserSID)) {
        # If multiple SID's are found in registry, look for the SID belonging to the logged on user
        if ($items.GetType().IsArray) {
            # LogonCredsAvailable needs to be set to 1, indicating that the credential provider is in use
            if ($items.Where({ $_.PSChildName -eq $loggedOnUserSID }).LogonCredsAvailable -eq 1) {
                return $true                
            }
            # If LogonCredsAvailable is not set to 1, this will indicate that the PIN credential provider is not in use
            elseif ($items.Where({ $_.PSChildName -eq $loggedOnUserSID }).LogonCredsAvailable -ne 1) {
                return $false
            }
            else {
                return $false
            }
        }
        # Looking for the SID belonging to the logged on user is slightly different if there's not mulitple SIDs found in registry
        else {
            if (($items.PSChildName -eq $loggedOnUserSID) -AND ($items.LogonCredsAvailable -eq 1)) {
                return $true
            }
            elseif (($items.PSChildName -eq $loggedOnUserSID) -AND ($items.LogonCredsAvailable -ne 1)) {
                return $false
            }
            else {
                return $false
            }
        }
    }
    else {
        return $false
    }
}

function CheckModernStandbyStatus {
    $availableStates = powercfg /a
    $availableStatesStartIndex = $availableStates.IndexOf("The following sleep states are available on this system:")
    $availableStatesEndIndex = $availableStates.IndexOf("The following sleep states are not available on this system:")

    if ($availableStatesStartIndex -eq -1) {
        return $false
    }
    else {
        $availableStatesStartIndex = $availableStatesStartIndex + 1
    }

    if ($availableStatesEndIndex -eq -1) {
        $availableStatesEndIndex = $availableStates.Count
    }
    else {
        $availableStatesEndIndex = $availableStatesEndIndex - 1
    }

    for ($index = $availableStatesStartIndex; $index -le $availableStatesEndIndex; $index++ ) {
        if ($availableStates[$index].Contains("Standby (S0 Low Power Idle")) {
            return $true
        }
    }

    return $false
}

function CheckWindowsRecoveryEnvironmentStatus {
    return ($(ReAgentc.exe /info) -match "Windows RE status:         Enabled").count -gt 0
}

function CheckSecurity {
    EnsureElevated

    $dmaProtection = CheckDmaProtectionStatus
    if ($dmaProtection) {
        Write-Host "[  OK  ] Kernel DMA Protection is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Kernel DMA Protection is disabled" -ForegroundColor Red
    }    

    $virtualizationBasedSecurity = CheckVirtualizationBasedSecurityStatus
    if ($virtualizationBasedSecurity) {
        Write-Host "[  OK  ] Virtualization Based Security is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Virtualization Based Security is disabled" -ForegroundColor Red
    }

    $codeIntegrityPolicyEnforcement = CheckCodeIntegrityPolicyEnforcement
    if ($codeIntegrityPolicyEnforcement) {
        Write-Host "[  OK  ] Code Integrity Policy Enforcement is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Code Integrity Policy Enforcement is disabled" -ForegroundColor Red
    }

    $tpmStatus = CheckTpmStatus
    if ($tpmStatus) {
        Write-Host "[  OK  ] TPM is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] TPM is disabled" -ForegroundColor Red
    }

    $secureBootStatus = CheckSecureBootStatus
    if ($secureBootStatus) {
        Write-Host "[  OK  ] Secure Boot is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Secure Boot is disabled" -ForegroundColor Red
    }

    $bitlockerStatus = CheckBitlockerStatus
    if ($bitlockerStatus) {
        Write-Host "[  OK  ] Bitlocker is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Bitlocker is disabled" -ForegroundColor Red
    }

    $deviceEncryptionStatus = CheckDeviceEncryptionStatus
    if ($deviceEncryptionStatus) {
        Write-Host "[  OK  ] Device Encryption is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Device Encryption is disabled" -ForegroundColor Red
    }

    $windowsHelloStatus = CheckWindowsHelloStatus
    if ($windowsHelloStatus) {
        Write-Host "[  OK  ] Windows Hello is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Windows Hello is disabled" -ForegroundColor Red
    }

    $modernStandbyStatus = CheckModernStandbyStatus
    if ($modernStandbyStatus) {
        Write-Host "[  OK  ] Modern Standby is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Modern Standby is disabled" -ForegroundColor Red
    }

    $windowsRecoveryEnvironmentStatus = CheckWindowsRecoveryEnvironmentStatus
    if ($windowsRecoveryEnvironmentStatus) {
        Write-Host "[  OK  ] Windows Recovery Environment is enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[ FAIL ] Windows Recovery Environment is disabled" -ForegroundColor Red
    }
}

CheckSecurity