# My Windows Configuration script

These scripts are for my personal usage to configure a ready-to-use Windows environment for me.

## Warning

This project may NOT be designed for YOU!

Do NOT run it on your computer!!! May ruin your key!

## One-key install

Open Windows PowerShell(Admin)

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/Anduin2017/configuration-script-win/raw/main/install.ps1'))
```

![image](https://user-images.githubusercontent.com/19531547/127482010-6f8d35f8-37c5-472a-97ae-a75c16aa3699.png)

## How can I use this project?

You need to **fork** this repo, and modify some configuration path in the source code.

For example:

* I copied my SSH private key file from my OneDrive. Which requires you to modify those logic.
* I setup git to use my own email address. Which requires you to modify those configuration.
* I used the script to test my own project to verify that my development environment works fine. Which requires you to modify those configration.
