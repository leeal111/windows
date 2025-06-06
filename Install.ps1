param (
    [ValidateSet("Install", "Uninstall")]
    [string]$OptionType = "Install"
)

# 检查是否以管理员身份运行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "错误：请以管理员身份运行此脚本。"
    exit
}

# 安装 WSL
$params = @{
    Distro = "Ubuntu"
}
& ".\install\wsl.ps1" @params

# 安装 Code 项目的环境
& ".\install\code.ps1"

# 安装 AutoHotkey
& ".\install\ahk.ps1"

# 注册系统变量 Path
& ".\install\path.ps1"

# 安装 Wezterm
# 暂未实现

# 注册 AHK 脚本
& ".\install\start.ps1"

# 注册任务自动化启动
& ".\install\register.ps1"
