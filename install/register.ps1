param (
    [ValidateSet("Install", "Uninstall")]
    [string]$OptionType = "Install"
)

. .\data\tasks.ps1
. .\util\utils.ps1

if ($OptionType -eq "Install") {
    
    $currentPath = Get-Location

    foreach ($task in $G_tasks) {
        
        # 定义任务触发器
        $time12Hour = ConvertTo12HourFormat -time24Hour $task.Time
        $trigger = New-ScheduledTaskTrigger -Daily -At $time12Hour
    
        # 定义任务操作
        $scriptPath = Join-Path -Path $currentPath -ChildPath $task.AHK
        $action = New-ScheduledTaskAction -Execute $scriptPath
    
        # 创建计划任务
        $fileNameWithExtension = Split-Path -Path $task.AHK -Leaf
        $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fileNameWithExtension)
        Register-ScheduledTask -TaskName $fileNameWithoutExtension -Trigger $trigger -Action $action -RunLevel Highest
    }
}
elseif ($OptionType -eq "Uninstall") {
    foreach ($task in $G_tasks) {
        $fileNameWithExtension = Split-Path -Path $task.AHK -Leaf
        $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fileNameWithExtension)
        Unregister-ScheduledTask -TaskName $fileNameWithoutExtension -Confirm:$false
    }
}
else {
    Write-Host "Invalid OptionType: $OptionType"
}