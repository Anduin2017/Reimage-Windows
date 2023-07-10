Add-Type -AssemblyName System.Drawing

function Sync-Spotlight {
    # 设置变量以指定源和目标文件夹的路径
    $sourceFolder = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
    $destinationFolder = "$env:HOMEPATH\Pictures\Spotlight"
    New-Item -Type Directory -Path $destinationFolder -ErrorAction SilentlyContinue

    # 筛选出所有没有文件扩展名的文件，并且宽度大于高度的图片
    Get-ChildItem $sourceFolder | Where-Object { $_.Extension -eq "" -and $_.Length -gt 100KB } | ForEach-Object {
        $imageSize = Get-ImageSize $_.FullName
        if ($imageSize.Width -gt $imageSize.Height) {
            # 将文件复制到目标文件夹，并将其重命名为.jpg文件
            Copy-Item $_.FullName "$destinationFolder\$($_.Name).jpg"
        }
    }

    Copy-Item -Path "$env:HOMEPATH\Pictures\Spotlight\" -Recurse -Destination "$env:HOMEPATH\Nextcloud\Digital\Wallpapers\" -Verbose -ErrorAction SilentlyContinue
}

function Get-ImageSize {
    param([string]$imagePath)
    $image = [System.Drawing.Image]::FromFile($imagePath)
    $size = New-Object System.Management.Automation.PSObject -Property @{
        Width = $image.Width
        Height = $image.Height
    }
    $image.Dispose()
    return $size
}


Export-ModuleMember -Function Sync-Spotlight