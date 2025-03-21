# ����: ��ָ��Ŀ¼��ű�����Ŀ¼��ӵ�����������

param (
    [string]$Path # Ҫ��ӵ�����������·��
)

# �������ַ����Ƿ��ǺϷ���·��
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
    Write-Output "�ṩ��·�� '$Path' ����һ���Ϸ���·����"
    exit
}

# ���û���ṩ·����������ʹ�ýű����ڵ�·��
if (-not $Path) {
    $Path = (Get-Location).Path
}

# ��ȡ���������е�·��
$envPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

# ���ָ��Ŀ¼�Ƿ��ڻ���������
if ($envPath -notlike "*$Path*") {
    # ������ڻ��������У������ָ��Ŀ¼����������
    $newPath = "$envPath;$Path"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Output "Ŀ¼ '$Path' ����ӵ����������С�"
}
else {
    Write-Output "Ŀ¼ '$Path' ���ڻ��������С�"
}