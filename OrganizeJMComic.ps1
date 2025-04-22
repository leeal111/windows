# ����: ���ڽ����������������ļ�������Ϊѹ������ɾ��ԭ�ļ���

param (
    [Parameter(Mandatory = $true, HelpMessage = "����ָ����������")]
    [string]$AuthorName    # �������ƣ����ڱ���·������·��
)

# ���� 
$7zPath = "C:\Program Files\7-Zip\7z.exe"  # 7-Zip ��ִ���ļ�·��
$srcDir = "D:\PortableDir\1-fun\0-other\jmcomic\data\commies" # Դ�ļ���·��
$desDir = "D:\PortableDir\1-fun\0-other\1-comic" # Ŀ���ļ���·��

$desDir = Join-Path -Path $desDir -ChildPath $AuthorName
Write-Host "Ŀ��·��Ϊ��$desDir`n"

# ��� 7-Zip �Ƿ����
if (-not (Test-Path $7zPath)) {
    Write-Error "7-Zip δ�ҵ�����ȷ���Ѱ�װ 7-Zip��"
    exit 1
}

if (-not (Test-Path $srcDir)) {
    Write-Error "srcDir δ�ҵ���"
    exit 1
}

# ��ȡĿ��Ŀ¼�µ������ļ���
$folders = Get-ChildItem -Path $srcDir -Directory

$count = 0
foreach ($folder in $folders) {
    $contentPath = Join-Path -Path $folder.FullName -ChildPath "original" # ��������·��
    $zipFileName = Join-Path -Path $desDir -ChildPath "$($folder.Name).zip" # ѹ�������·��

    if (Test-Path -LiteralPath $contentPath) {
        # ����Ƿ�ֻ��һ�����ļ��У�����ǣ���ֱ��ѹ��������ļ���
        $folders__ = Get-ChildItem -LiteralPath $contentPath -Directory
        $folderCount = $folders__.Count
        if ($folderCount -eq 1) {
            $contentPath = Join-Path -Path $contentPath -ChildPath "��1��"
        }

        # 7-Zip ѹ������
        $arguments = @(
            "a", # ����ļ���ѹ����
            "-tzip", # ѹ����ʽΪ ZIP
            "-mx=9", # ���ѹ����
            "-sse", # ������ļ�����д��
            """$zipFileName""", # ѹ����·��
            """$contentPath\**""" # Ҫѹ��������·��
        )

        # ִ��ѹ������
        & "$7zPath" $arguments > $null 2>&1

        # ���ѹ�����
        if ($LASTEXITCODE -eq 0) {
            Write-Host "ѹ���ɹ�: $($folder.Name)"
            $count++
        }
        else {
            Write-Warning "ѹ��ʧ��: $($folder.Name) (�������: $LASTEXITCODE)"
        }
    }
    else {
        Write-Warning "·��������: $contentPath"
    }

}

Write-Host "`n���� $count ��ѹ���������"

if ($count -eq $folders.Count) {
    foreach ($folder in $folders) {
        $folderPath = $folder.FullName
        Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
    }
    Write-Host "�����ļ����Ѵ���ɾ����"
}
else {
    Write-Host "����ʧ�ܵ�ѹ���������飡"
}