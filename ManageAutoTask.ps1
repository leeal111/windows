param (
    [ValidateSet("Add", "Remove")]
    [string]$OptionType
)

# 定义任务数组，每个任务包含名称、触发器时间和脚本路径
$tasks = @(
    @{ 
        Name   = "GenshinImpact"
        Time   = "12:30"
        Param = "-File C:\Users\fumen\OneDrive\script\BootGameAutoTool.ps1 -GameName GenshinImpact" 
    }
    @{ 
        Name   = "StarRail"
        Time   = "18:05"
        Param = "-File C:\Users\fumen\OneDrive\script\BootGameAutoTool.ps1 -GameName StarRail" 
    }
    @{ 
        Name   = "Arknights"
        Time   = "07:30"
        Param = "-File C:\Users\fumen\OneDrive\script\BootGameAutoTool.ps1 -GameName Arknights" 
    }
    @{ 
        Name   = "Arknights2"
        Time   = "18:00"
        Param = "-File C:\Users\fumen\OneDrive\script\BootGameAutoTool.ps1 -GameName Arknights" 
    }
)

function ConvertTo12HourFormat {
    param (
        [string]$time24Hour
    )

    # Parse the input time
    $time = [datetime]::ParseExact($time24Hour, 'HH:mm', $null)

    # Convert to 12-hour format with AM/PM using invariant culture
    $time12Hour = $time.ToString('hh:mmtt', [System.Globalization.CultureInfo]::InvariantCulture)

    return $time12Hour
}

if ($OptionType -eq "Add") {
    foreach ($task in $tasks) {
        
        # 定义任务触发器
        $time12Hour = ConvertTo12HourFormat -time24Hour $task.Time
        $trigger = New-ScheduledTaskTrigger -Daily -At $time12Hour
    
        # 定义任务操作
        $action = New-ScheduledTaskAction -Execute "powershell" -Argument $task.Param
    
        # 创建计划任务
        Register-ScheduledTask -TaskName $task.Name -Trigger $trigger -Action $action -RunLevel Highest
    }
}
elseif ($OptionType -eq "Remove") {
    foreach ($task in $tasks) {
        Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false
    }
}
else {
    Write-Host "Invalid OptionType: $OptionType"
}