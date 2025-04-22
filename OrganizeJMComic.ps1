# 描述: 用于将下载下来的漫画文件夹整理为压缩包并删除原文件夹

param (
    [Parameter(Mandatory = $true, HelpMessage = "必须指定作者名称")]
    [string]$AuthorName    # 作者名称，用于保存路径的子路径
)

# 参数 
$7zPath = "C:\Program Files\7-Zip\7z.exe"  # 7-Zip 可执行文件路径
$srcDir = "D:\PortableDir\1-fun\0-other\jmcomic\data\commies" # 源文件夹路径
$desDir = "D:\PortableDir\1-fun\0-other\1-comic" # 目标文件夹路径

$desDir = Join-Path -Path $desDir -ChildPath $AuthorName
Write-Host "目标路径为：$desDir`n"

# 检查 7-Zip 是否存在
if (-not (Test-Path $7zPath)) {
    Write-Error "7-Zip 未找到，请确保已安装 7-Zip。"
    exit 1
}

if (-not (Test-Path $srcDir)) {
    Write-Error "srcDir 未找到。"
    exit 1
}

# 获取目标目录下的所有文件夹
$folders = Get-ChildItem -Path $srcDir -Directory

$count = 0
foreach ($folder in $folders) {
    $contentPath = Join-Path -Path $folder.FullName -ChildPath "original" # 漫画输入路径
    $zipFileName = Join-Path -Path $desDir -ChildPath "$($folder.Name).zip" # 压缩包输出路径

    if (Test-Path -LiteralPath $contentPath) {
        # 检查是否只有一个子文件夹，如果是，则直接压缩这个子文件夹
        $folders__ = Get-ChildItem -LiteralPath $contentPath -Directory
        $folderCount = $folders__.Count
        if ($folderCount -eq 1) {
            $contentPath = Join-Path -Path $contentPath -ChildPath "第1话"
        }

        # 7-Zip 压缩参数
        $arguments = @(
            "a", # 添加文件到压缩包
            "-tzip", # 压缩格式为 ZIP
            "-mx=9", # 最大压缩率
            "-sse", # 允许打开文件进行写入
            """$zipFileName""", # 压缩包路径
            """$contentPath\**""" # 要压缩的内容路径
        )

        # 执行压缩命令
        & "$7zPath" $arguments > $null 2>&1

        # 检查压缩结果
        if ($LASTEXITCODE -eq 0) {
            Write-Host "压缩成功: $($folder.Name)"
            $count++
        }
        else {
            Write-Warning "压缩失败: $($folder.Name) (错误代码: $LASTEXITCODE)"
        }
    }
    else {
        Write-Warning "路径不存在: $contentPath"
    }

}

Write-Host "`n共计 $count 项压缩任务完成"

if ($count -eq $folders.Count) {
    foreach ($folder in $folders) {
        $folderPath = $folder.FullName
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
    }
    Write-Host "所有文件夹已处理并删除。"
}
else {
    Write-Host "存在失败的压缩任务，请检查！"
}