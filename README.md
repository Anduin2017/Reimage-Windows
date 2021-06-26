# configuration-script-win

These scripts are for my personal usage to configure a ready-to-use Windows environment for me.

## Warning

This project may NOT be designed for YOU!

Do NOT run it on your computer!!! May ruin your key!

## One-key install

Open Windows PowerShell(Admin)

```powershell
Set-ExecutionPolicy remotesigned
$Script = Invoke-WebRequest 'https://raw.githubusercontent.com/Anduin2017/configuration-script-win/master/install.ps1'
$ScriptBlock = [Scriptblock]::Create($Script.Content)
Invoke-Command -ScriptBlock $ScriptBlock
```
