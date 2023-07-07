function GetWallpaper {
    $bytes = (New-Object -ComObject WScript.Shell).RegRead("HKEY_CURRENT_USER\Control Panel\Desktop\TranscodedImageCache")
    $wallpaperpath = [System.Text.Encoding]::Unicode.GetString($bytes[24..($bytes.length - 1)])
    $wallpaperpath = $wallpaperpath.substring(0, $wallpaperpath.IndexOf("jpg", 0, $wallpaperpath.Length) + 3)
    return $wallpaperpath
}

Export-ModuleMember -Function GetWallpaper