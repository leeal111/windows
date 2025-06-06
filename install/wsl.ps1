param (
    [ValidateSet("Install", "Uninstall")]
    [string]$OptionType = "Install",

    [string]$Distro
)

if ($OptionType -eq "Install") {
    try {
        # 启用 WSL 功能
        Write-Host "正在启用 WSL 功能..."
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "WSL 功能已启用。"
        }
        else {
            Write-Host "启用 WSL 功能失败，请检查系统兼容性。"
            exit
        }

        # 启用虚拟机平台（WSL2 依赖）
        Write-Host "正在启用虚拟机平台..."
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "虚拟机平台已启用。"
        }
        else {
            Write-Host "启用虚拟机平台失败，请检查系统兼容性。"
            exit
        }

        # 设置 WSL2 为默认版本
        Write-Host "正在设置 WSL2 为默认版本..."
        wsl --set-default-version 2
        if ($LASTEXITCODE -eq 0) {
            Write-Host "WSL2 已设置为默认版本。"
        }
        else {
            Write-Host "设置 WSL2 默认版本失败，请检查 WSL 更新。"
            exit
        }

        # （可选）安装指定 Linux 发行版
        if ($Distro) {
            Write-Host "正在安装 Linux 发行版：$Distro..."
            wsl --install -d $Distro
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$Distro 安装成功。请重启系统以完成配置。"
            }
            else {
                Write-Host "安装 $Distro 失败，请检查网络连接或发行版名称。"
                exit
            }
        }

        # 提示重启
        Write-Host "请重启计算机以应用更改。"
    }
    catch {
        Write-Host "安装 WSL 失败：$_"
    }
}
elseif ($OptionType -eq "Uninstall") {
    # TODO
}
else {
    Write-Host "Invalid OptionType: $OptionType"
}

