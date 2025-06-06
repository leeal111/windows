try {
    # 获取最新版本的下载链接
    Write-Host "正在获取 AutoHotkey 最新版本信息..."
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/AutoHotkey/AutoHotkey/releases/latest"
    $version = $releaseInfo.tag_name
    $downloadUrl = $releaseInfo.assets | Where-Object { $_.name -like "AutoHotkey_*.zip" } | Select-Object -ExpandProperty browser_download_url
    if (-not $downloadUrl) {
        Write-Host "无法获取最新版本的下载链接，请检查网络连接或 GitHub API。"
        exit
    }

    # 设置安装路径和临时文件路径
    $installPath = "$env:ProgramFiles\AutoHotkey"
    $tempPath = "$env:TEMP\AutoHotkey_$version.zip"

    # 下载 AutoHotkey
    Write-Host "正在下载 AutoHotkey $version..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath
    if (Test-Path $tempPath) {
        Write-Host "AutoHotkey 下载成功。"
    }
    else {
        Write-Host "下载 AutoHotkey 失败，请检查网络连接。"
        exit
    }

    # 解压安装文件
    Write-Host "正在解压 AutoHotkey 安装文件..."
    Expand-Archive -Path $tempPath -DestinationPath $installPath -Force
    if (Test-Path "$installPath\AutoHotkey.exe") {
        Write-Host "AutoHotkey 解压成功。"
    }
    else {
        Write-Host "解压 AutoHotkey 失败，请检查文件完整性。"
        exit
    }

    # 添加 AutoHotkey 到环境变量
    Write-Host "正在添加 AutoHotkey 到系统环境变量..."
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($currentPath -notlike "*$installPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", [EnvironmentVariableTarget]::Machine)
        Write-Host "AutoHotkey 已添加到环境变量。"
    }
    else {
        Write-Host "AutoHotkey 已存在于环境变量中，无需重复添加。"
    }

    Write-Host "AutoHotkey 安装完成！您现在可以运行 .ahk 脚本。"
}
catch {
    Write-Host "安装 AutoHotkey 失败：$_"
}