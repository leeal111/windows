param (
    [ValidateSet("Install", "Uninstall")]
    [string]$OptionType = "Install"
)

$taskName = "MainAHK_AutoStart"

if ($OptionType -eq "Install") {
    # 获取当前路径
    $currentPath = Get-Location

    # 检查 main.ahk 是否存在
    $scriptPath = Join-Path -Path $currentPath -ChildPath "main.ahk"
    if (-Not (Test-Path $scriptPath)) {
        Write-Error "main.ahk 文件不存在！"
        exit 1
    }

    # 定义计划任务参数
    $action = New-ScheduledTaskAction -Execute $scriptPath
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    # 注册计划任务
    try {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -RunLevel Highest
        Write-Host "已成功注册计划任务：$taskName，main.ahk 将在开机时以管理员权限运行！"
    }
    catch {
        Write-Error "注册计划任务失败：$_"
        exit 1
    }
}
elseif ($OptionType -eq "Uninstall") {
    try {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false 
    }
    catch {
        Write-Error "卸载计划任务失败：$_"
        exit 1
    }   
    Write-Host "已成功卸载计划"
}
else {
    Write-Host "Invalid OptionType: $OptionType"
}
