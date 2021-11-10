# My Windows Configuration script

These scripts are for my personal usage to configure a ready-to-use Windows environment for me.

## Re-install Windows

The following command will re-install Windows 10\11\insider for you.

Right click the start button, click `Windows PowerShell(Admin)`.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/Reimage.ps1'))
```

It will ask you the downloaded Windows ISO file. You can download it with any tool you like, and provide it the file.

It will ask you for a clean disk drive. For example: Disk `E:\`. Provide it any disk you like.


In China? There is a proxy for China network which bypass the firewall.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://githubcontent.aiurs.co/Anduin2017/configuration-script-win/main/Reimage.ps1'))
```

## Warning

This next part may NOT be designed for YOU!

Do NOT run it on your computer!!! May ruin your key!

## One-key install

Right click the start button, click `Windows PowerShell(Admin)`.

[Edit now](https://github.com/Anduin2017/configuration-script-win/edit/main/install.ps1)

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/install.ps1'))
```

In China? There is a proxy for China network which bypass the firewall.

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://githubcontent.aiurs.co/Anduin2017/configuration-script-win/main/install.ps1'))
```

**Caution: DO NOT RUN this in Windows Terminal!!! Instead, start a pure PowerShell with admin instead!**

![image](https://user-images.githubusercontent.com/19531547/127482010-6f8d35f8-37c5-472a-97ae-a75c16aa3699.png)

## How can I use this project?

You need to **fork** this repo, and modify some configuration path in the source code.

For example:

* I copied my SSH private key file from my OneDrive. Which requires you to modify those logic.
* I copied my Windows Terminal configuration file from my OneDrive. Which requires you to modify those logic.
