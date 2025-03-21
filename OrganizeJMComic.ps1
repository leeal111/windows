# 描述: 用于将下载下来的漫画文件夹整理为压缩包并删除原文件夹

param (
    [string]$AuthorName    # 作者名称，用于保存路径的子路径
)

# 参数 
$7zPath = "C:\Program Files\7-Zip\7z.exe"  # 7-Zip 可执行文件路径
$srcDir = "D:\PortableDir\0-other\0-18x\jmcomic_v1.2.6_windows_x64\data\commies" # 源文件夹路径
$desDir = Join-Path -Path "D:\PortableDir\0-other\0-18x\1-comic" -ChildPath $AuthorName # 目标文件夹路径

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

# 初始化一个空数组，用于存储所有子文件夹路径
$allSubFolders = @()

# 获取目标目录下的所有文件夹
$folders = Get-ChildItem -Path $srcDir -Directory

# 遍历每个文件夹，获取其下一级的所有子文件夹
foreach ($folder in $folders) {
    $subFolders = Get-ChildItem -Path $folder.FullName -Directory
    $allSubFolders += $subFolders
}

$count = 0
foreach ($folder in $allSubFolders) {
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

if ($count -eq $allSubFolders.Count) {
    foreach ($folder in $folders) {
        $folderPath = $folder.FullName
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
    }
    Write-Host "所有文件夹已处理并删除。"
}
else {
    Write-Host "存在失败的压缩任务，请检查！"
}