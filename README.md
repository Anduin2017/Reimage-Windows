# Re-image the Windows

These scripts configure a ready-to-use Windows environment.

## Re-install Windows

The following command will re-install Windows 10\11\insider for you.

Right-click the start button, and click `Windows PowerShell`(Admin)`.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/Reimage.ps1'))
```

* It will ask you for the downloaded Windows ISO file. You can download it with any tool you like, and provide it the file name.
* It will ask you for a clean disk drive. For example Disk `E:\``. Provide it with any disk you like. (Except current OS drive)

## Warning

This next part may NOT be designed for YOU! It is for my usage to config the newly installed Windows as a ready-to-use state.

You need to **fork** this repository and modify some configuration paths in the source code.

For example:

* I copied my SSH private key file from my OneDrive. Which requires you to modify that logic.
* I copied my Windows Terminal configuration file from my OneDrive. Which requires you to modify that logic.

### One-key post config

Right-click the start button, and click `Windows PowerShell`(Admin)`.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/install.ps1'))
```

Caution: **DO NOT RUN** this in Windows Terminal!!! Instead, start a pure PowerShell with admin instead!

#### V2

```powershell
$destinationPath = "$env:TEMP\reimage-windows-master.zip"
Invoke-WebRequest -Uri "https://gitlab.aiursoft.cn/anduin/reimage-windows/-/archive/master/reimage-windows-master.zip" -OutFile $destinationPath
Expand-Archive -Path $destinationPath -DestinationPath $env:TEMP
Remove-Item $destinationPath
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
. "$env:TEMP\reimage-windows-master\install_v2.ps1"
```

### One-key test current environment

Open PowerShell and run:

```powershell
$(Invoke-WebRequest https://gitlab.aiursoft.cn/anduin/reimage-windows/-/raw/master/test_env.sh).Content | bash
```
