function CreateShortcut {
    param(
        [string]$path,
        [string]$name
    )
    $envPrograms = [Environment]::GetFolderPath("Programs")
    $shortcutPath = Join-Path $envPrograms "$name.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $path
    $Shortcut.Save()
}

Export-ModuleMember -Function CreateShortcut