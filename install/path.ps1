# 描述: 将脚本所在目录下的 script 文件夹添加到系统环境变量中

function AddPath {
    param (
        [string]$scriptName
    )

    try {
        # 获取脚本所在目录下的 script 文件夹路径
        $scriptDir = Join-Path -Path (Get-Location).Path -ChildPath $scriptName
    
        
        # 检查 script 文件夹是否存在
        if (-not (Test-Path -Path $scriptDir -PathType Container)) {
            Write-Host "script 文件夹 '$scriptDir' 不存在。"
            exit
        }
    

        # 获取系统环境变量中的 Path
        Write-Host "正在获取系统环境变量 Path..."
        $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    
        # 检查 script 文件夹是否已在环境变量中
        if ($envPath -notlike "*$scriptDir*") {
            # 如果不在环境变量中，则添加 script 文件夹到系统环境变量
            Write-Host "正在将 script 文件夹 '$scriptDir' 添加到系统环境变量..."
            $newPath = "$envPath;$scriptDir"
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
            Write-Host "script 文件夹 '$scriptDir' 已成功添加到系统环境变量。"
        }
        else {
            Write-Host "script 文件夹 '$scriptDir' 已在系统环境变量中，无需重复添加。"
        }
    }
    catch {
        Write-Host "添加 script 文件夹到系统环境变量失败：$_"
    }
} 

AddPath("script")