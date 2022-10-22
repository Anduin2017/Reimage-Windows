# Reimage the Windows

These scripts to configure a ready-to-use Windows environment.

## Re-install Windows

The following command will re-install Windows 10\11\insider for you.

Right click the start button, click `Windows PowerShell(Admin)`.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://git.aiursoft.cn/Anduin/configuration-script-win/raw/branch/main/Reimage.ps1'))
```

* It will ask you the downloaded Windows ISO file. You can download it with any tool you like, and provide it the file name.
* It will ask you for a clean disk drive. For example: Disk `E:\`. Provide it with any disk you like. (Except current OS drive)

# Warning

This next part may NOT be designed for YOU! It is for my personal usage to config the newly installed Windows as a ready to use state.

You need to **fork** this repo, and modify some configuration path in the source code.

For example:

* I copied my SSH private key file from my OneDrive. Which requires you to modify those logic.
* I copied my Windows Terminal configuration file from my OneDrive. Which requires you to modify those logic.

### One-key post config

Right click the start button, click `Windows PowerShell(Admin)`.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://git.aiursoft.cn/Anduin/configuration-script-win/raw/branch/main/install.ps1'))
```

**Caution: DO NOT RUN this in Windows Terminal!!! Instead, start a pure PowerShell with admin instead!**

### One-key post config for Ubuntu

Open bash, and run:

```bash
sudo apt install -y curl && curl "https://git.aiursoft.cn/Anduin/configuration-script-win/raw/branch/main/ubuntu.sh" --output - | sudo bash
```

### One-key test current environment

Open PowerShell and run:

```powershell
$(Invoke-WebRequest https://git.aiursoft.cn/Anduin/configuration-script-win/raw/branch/main/test_env.sh).Content | bash
```
