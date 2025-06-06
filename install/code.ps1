try {
    # 创建工作区目录
    wsl bash -c "mkdir ~/ws"

    # 拉取 Code 项目代码
    wsl bash -c "cd ~/ws && git clone https://github.com/leeal111/code.git"

    # 开始执行安装脚本
    Write-Host "正在安装 Code："
    wsl bash -c "cd ~/ws/code && bash ./main.sh"

    Write-Host "Code 安装完成。"
}
catch {
    Write-Host "安装 Code 失败：$_"
}