# 描述: 将指定目录或脚本所在目录添加到环境变量中

param (
    [string]$Path # 要添加到环境变量的路径
)

# 检查给定字符串是否是合法的路径
function Test-ValidPath {
    param (
        [string]$Path
    )
    try {
        $null = [System.IO.Path]::GetFullPath($Path)
        return $true
    }
    catch {
        return $false
    }
}

if (-not (Test-ValidPath -Path $Path)) {
    Write-Output "提供的路径 '$Path' 不是一个合法的路径。"
    exit
}

# 如果没有提供路径参数，则使用脚本所在的路径
if (-not $Path) {
    $Path = (Get-Location).Path
}

# 获取环境变量中的路径
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

# 检查指定目录是否在环境变量中
if ($envPath -notlike "*$Path*") {
    # 如果不在环境变量中，则添加指定目录到环境变量
    $newPath = "$envPath;$Path"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Output "目录 '$Path' 已添加到环境变量中。"
}
else {
    Write-Output "目录 '$Path' 已在环境变量中。"
}