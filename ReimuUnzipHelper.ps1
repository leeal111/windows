# ��ָ��Ŀ¼�µ�����ѹ���ļ���ѹ������ѹ���ļ�ͬ����Ŀ¼��
# ֧�ֵݹ��ѹ
# ֧�ֶ�������

# ���̼�����
# 1. ��ȡ�������ݹ��ȡָ��Ŀ¼�����п�����ѹ���ļ����ļ�·��
# 2. ��ÿһ���ļ�ִ�еݹ��ѹ����
# ...... ���Ծ������ˣ�������ɡ�

# �߼��ɴ�ģ������п��ٸġ����ȣ��������ʱ���Դ��ϵ��µݹ��鵱ǰ�������ļ����Ƿ���ѹ���ļ�����ѹ�����ɵ��ļ��У�����Ǿ�������
# Ȼ�������߼����ѵ�һ��������ж��Ƿ���Ҫ�ٴν�ѹ���������ȷʵû���Զ�������ô�����Ըı乤������
# ������ڵ�һ�ν�ѹ���ȥ����Ѿ���ѹ��ɵ��ļ����ƶ��ߣ���ô�ٴ�ִ�нű��ֻص���Ĭ��״̬�����ֹ������Խű����Ѻá�

# ����
$7zPath = "C:\Program Files\7-Zip\7z.exe"  # 7-Zip ��ִ���ļ�·��
$folderPath = "D:\BaiduNetdiskDownload"    # ѹ���ļ�·��
$passwords = @(
    "��",
    "û������"
) # �����б�

$maxCount = 3 # ���ݹ����
$indent = "    " # ����
$filePaths = Get-ChildItem -Path $folderPath -Recurse -File -Include *.zip, *.rar, *.7z, *.jpg | Select-Object -ExpandProperty FullName # ��ȡ�����ļ�·��


# ͨ��ָ����ѹ���ļ�·����ȡ��ѹ��ı���·��
function Get-SavePath { 
    param (
        [string]$path 
    )
    # ��ȡ�ļ���Ŀ¼·��
    $directoryPath = [System.IO.Path]::GetDirectoryName($path)
    $fileName = [System.IO.Path]::GetFileName($path)
    $baseName = $fileName.Split('.')[0]
    $savePath = Join-Path -Path $directoryPath -ChildPath "$baseName"
    return $savePath
}

# ��ָ���ݹ���ȶ�ָ���ļ��ݹ��ѹ��
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

    # ����Ŀ¼����������ڣ�
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
                Write-Host "${combinedIndent}��ѹ�ɹ�: $savePath"
                $filePaths = Get-ChildItem -Path $savePath -File -Recurse -Include *.zip, *.rar, *.7z,*.dd | Select-Object -ExpandProperty FullName
                foreach ($path in $filePaths) {
                    $newCount = $count - 1
                    Expand-File -path $path -count $newCount
                }
                break
            } 
        }
        if (-not (Test-Path -LiteralPath $savePath)) {
            Write-Host "${combinedIndent}��ѹʧ�ܣ�$savePath"
        }
    }
    else {
        Write-Host "${combinedIndent}Ŀ¼�Ѵ��ڣ�$savePath"
    }
}

# ���������ļ�
foreach ($path in $filePaths) {
    Expand-File -path $path -count $maxCount
}