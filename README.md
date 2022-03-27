# Reimage the Windows

These scripts to configure a ready-to-use Windows environment.

## Re-install Windows

The following command will re-install Windows 10\11\insider for you.

Right click the start button, click `Windows PowerShell(Admin)`.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/Reimage.ps1'))
```

![image](https://user-images.githubusercontent.com/19531547/145162782-3e15f780-a1ee-4665-8af8-0d3b85ff103a.png)

* It will ask you the downloaded Windows ISO file. You can download it with any tool you like, and provide it the file name.
* It will ask you for a clean disk drive. For example: Disk `E:\`. Provide it with any disk you like. (Except current OS drive)

----------------

In China? There is a proxy for China network which bypass the firewall.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://githubcontent.aiurs.co/Anduin2017/configuration-script-win/main/Reimage.ps1'))
```
# Warning

This next part may NOT be designed for YOU! It is for my personal usage to config the newly installed Windows as a ready to use state.

You need to **fork** this repo, and modify some configuration path in the source code.

For example:

* I copied my SSH private key file from my OneDrive. Which requires you to modify those logic.
* I copied my Windows Terminal configuration file from my OneDrive. Which requires you to modify those logic.

### One-key post config

Right click the start button, click `Windows PowerShell(Admin)`.

[Edit now](https://github.com/Anduin2017/configuration-script-win/edit/main/install.ps1)

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/install.ps1'))
```

**Caution: DO NOT RUN this in Windows Terminal!!! Instead, start a pure PowerShell with admin instead!**

![image](https://user-images.githubusercontent.com/19531547/127482010-6f8d35f8-37c5-472a-97ae-a75c16aa3699.png)

### One-key post config for Ubuntu

Open bash, and run:

```bash
sudo apt install -y curl && curl "https://raw.githubusercontent.com/Anduin2017/configuration-script-win/main/ubuntu.sh" --output - | sudo bash
```
