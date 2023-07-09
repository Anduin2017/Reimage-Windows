Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\AddToPath.psm1" | Resolve-Path)
Import-Module (Join-Path -Path $PSCommandPath -ChildPath "..\..\tools\GetWallpaper.psm1" | Resolve-Path)


function SetupDesktop {

    Write-Host "Changing wallpaper..." -ForegroundColor Green
    $currentWallpaper = GetWallpaper
    if ($currentWallpaper -match "Windows")
    {
        Write-Host "Using default wallpaper!" -ForegroundColor Yellow
        $wallpaper = "$HOME\Nextcloud\Digital\Wallpapers\default.jpg"
        if (Test-Path $wallpaper) {
            Write-Host "Setting wallpaper to $wallpaper..." -ForegroundColor Green
            Set-WallPaper -Image $wallpaper
            Write-Host "Set to: " (Get-Item "$HOME\Nextcloud\Digital\Wallpapers\default.jpg").Name
        }
    }
    else
    {
        Write-Host "Wallpaper already set to: $currentWallpaper. Unchanged." -ForegroundColor Yellow
    }

    Write-Host "Set home path hidden folders and files..." -ForegroundColor Green
    Get-ChildItem -Path $HOME -Filter .* -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden }
    Write-Host "Hidden file hidded."

    Write-Host "Remove rubbish 3D objects..." -ForegroundColor Green
    Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}' -ErrorAction SilentlyContinue
    Write-Host "3D objects Removed."

    Write-Host "Enabling desktop icons..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "Desktop icons added."

    Write-Host "Disabling the Windows Ink Workspace..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name PenWorkspaceButtonDesiredVisibility -Value 0 -Type DWORD
    Write-Host "Ink Workspace disabled."

    Write-Host "Removing Bluetooth icons..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Control Panel\Bluetooth" -Name "Notification Area Icon" -Value 0 -Type DWORD
    Write-Host "Bluetooth icon removed."

    Write-Host "Hide explroer checkbox and launch to this PC..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWORD
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Value 0 -Type DWORD
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Type DWORD
    Write-Host "Explorer settings changed."

    Write-Host "Enabling dark theme..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
    Write-Host "Dark theme enabled."

    Write-Host "Setting mouse speed..." -ForegroundColor Green
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSensitivity -Value 6
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseSpeed -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseThreshold1 -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name MouseThreshold2 -Value 0
    Write-Host "Mouse speed changed. Will apply next reboot." -ForegroundColor Yellow

    Write-Host "Pin repos to quick access..." -ForegroundColor Green
    $load_com = new-object -com shell.application
    $load_com.Namespace("$env:USERPROFILE\source\repos").Self.InvokeVerb("pintohome")
    Write-Host "Repos folder are pinned to file explorer."

    Write-Host "Cleaning desktop..." -ForegroundColor Green
    Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

    Write-Host "Resetting desktop..." -ForegroundColor Yellow
    Stop-Process -Name explorer -Force

    Remove-Item $HOME\Desktop\* -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Public\Desktop\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
}

Export-ModuleMember -Function SetupDesktop