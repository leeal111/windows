# 将指定目录下的所有压缩文件解压缩到与压缩文件同名的目录下
# 支持递归解压
# 支持多种密码

# 流程简述：
# 1. 读取参数，递归获取指定目录的所有可能是压缩文件的文件路径
# 2. 对每一个文件执行递归解压缩，
# ...... 不对劲，算了，再想想吧。

# 逻辑可大改，但是有空再改。首先，在最外层时可以从上到下递归检查当前遍历的文件夹是否是压缩文件被解压后生成的文件夹，如果是就跳过。
# 然后整个逻辑最难的一点是如何判定是否还需要再次解压，这个操作确实没法自动化。那么，可以改变工作流。
# 如果我在第一次解压后就去检查已经解压完成的文件并移动走，那么再次执行脚本又回到了默认状态。这种工作流对脚本很友好。

# 参数
$7zPath = "C:\Program Files\7-Zip\7z.exe"  # 7-Zip 可执行文件路径
$folderPath = "D:\BaiduNetdiskDownload"    # 压缩文件路径
$passwords = @(
    "⑨",
    "没有密码"
) # 密码列表

$maxCount = 3 # 最大递归深度
$indent = "    " # 缩进
$filePaths = Get-ChildItem -Path $folderPath -Recurse -File -Include *.zip, *.rar, *.7z, *.jpg | Select-Object -ExpandProperty FullName # 获取所有文件路径


# 通过指定的压缩文件路径获取解压后的保存路径
function Get-SavePath { 
    param (
        [string]$path 
    )
    # 获取文件的目录路径
    $directoryPath = [System.IO.Path]::GetDirectoryName($path)
    $fileName = [System.IO.Path]::GetFileName($path)
    $baseName = $fileName.Split('.')[0]
    $savePath = Join-Path -Path $directoryPath -ChildPath "$baseName"
    return $savePath
}

# 以指定递归深度对指定文件递归解压缩
function Expand-File {
    param (
        [string]$path,
        [int]$count
    )
    $indentCount = $maxCount - $count
    $combinedIndent = $indent * $indentCount

    if ($count -eq 0) {
        return
    }

    $savePath = Get-SavePath $path

    # 创建目录（如果不存在）
    if (-not (Test-Path -Path $savePath)) {
        foreach ($password in $passwords) {
            $arguments = @(
                "x",
                "-y",
                "-p$password",
                """$path""", 
                "-o`"$savePath`"" 
            )
    
            & "$7zPath" $arguments > $null 2>&1
    
            if ($LASTEXITCODE -eq 0) {
                Write-Host "${combinedIndent}解压成功: $savePath"
                $filePaths = Get-ChildItem -Path $savePath -File -Recurse -Include *.zip, *.rar, *.7z,*.dd | Select-Object -ExpandProperty FullName
                foreach ($path in $filePaths) {
                    $newCount = $count - 1
                    Expand-File -path $path -count $newCount
                }
                break
            } 
        }
        if (-not (Test-Path -LiteralPath $savePath)) {
            Write-Host "${combinedIndent}解压失败：$savePath"
        }
    }
    else {
        Write-Host "${combinedIndent}目录已存在：$savePath"
    }
}

# 遍历所有文件
foreach ($path in $filePaths) {
    Expand-File -path $path -count $maxCount
}