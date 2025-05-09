param (
    [Parameter(Mandatory = $true, HelpMessage = "����ָ��Ӧ������", ParameterSetName = "Default")]
    [string]$GameName,

    [Parameter(Mandatory = $false, ParameterSetName = "Help")]
    [Alias("h", "help")]
    [switch]$HelpSwitch
)

if ($HelpSwitch) {
    Write-Host "֧�ֵ���Ϸ���ƣ�"
    foreach ($key in @( "GenshinImpact", "StarRail", "Arknights", "ZenlessZoneZero", "BlueArchive")) {
        Write-Host "- $key"
    }
    exit
}

$dataPath = "C:\Users\fumen\OneDrive\script\ClickData" # ���ݴ洢·��
$programMap = @{
    GenshinImpact   = "D:\PortableDir\BetterGI_v0.42.0\BetterGI.exe"
    StarRail        = "D:\PortableDir\March7thAssistant_v2024.12.18_full\March7th Launcher.exe"
    Arknights       = "D:\PortableDir\MAA-v5.11.1-win-x64\MAA.exe"
    ZenlessZoneZero = "D:\PortableDir\ZenlessZoneZero-OneDragon\OneDragon Launcher.exe"
    BlueArchive     = "D:\PortableDir\BlueArchiveAutoScript_v1_2_0_x86_64\BlueArchiveAutoScript_v1_2_0_x86_64.exe"
}

$eventMap = @{}
$jsonFiles = Get-ChildItem -Path $dataPath
foreach ($file in $jsonFiles) {
    $key = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)
    $jsonContent = Get-Content -Path $file.FullName -Raw
    $coordinates = $jsonContent | ConvertFrom-Json
    $eventMap[$key] = $coordinates
}

$mouseScript = @"

using System;
using System.Runtime.InteropServices;
using System.Threading;

public class Mouse
{
    // ���ָ��λ��
    public static void ClickAt(int x, int y)
    {
        // �ƶ���굽Ŀ��λ��
        SendMouseEvent(MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE, x, y);
        
        // ģ�����������º��ͷ�
        SendMouseEvent(MOUSEEVENTF_LEFTDOWN, 0, 0);
        SendMouseEvent(MOUSEEVENTF_LEFTUP, 0, 0);
    }
        
    // ��������¼�
    private static void SendMouseEvent(uint flags, int x, int y)
    {
        INPUT input = new INPUT
        {
            type = INPUT_MOUSE,
            mi = new MOUSEINPUT
            {
                dx = x,
                dy = y,
                mouseData = 0,
                dwFlags = flags,
                time = 0,
                dwExtraInfo = IntPtr.Zero
            }
        };

        // ���ھ������꣬��Ҫ�� dx �� dy ת��Ϊ 0-65535 ��Χ
        if ((flags & MOUSEEVENTF_ABSOLUTE) != 0)
        {
            int screenWidth = GetScreenWidth();
            int screenHeight = GetScreenHeight();

            input.mi.dx = (x * 65535) / screenWidth;
            input.mi.dy = (y * 65535) / screenHeight;

            input.mi.dwFlags |= MOUSEEVENTF_VIRTUALDESK; // ֧�ֶ���ʾ��
        }

        uint result = SendInput(1, new INPUT[] { input }, Marshal.SizeOf(typeof(INPUT)));
        if (result == 0)
        {
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        }
    }

    
    // ��ȡ��Ļ��Ⱥ͸߶�
    public static int GetScreenWidth()
    {
        IntPtr hdc = GetDC(IntPtr.Zero);
        if (hdc == IntPtr.Zero)
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());

        try
        {
            int width = GetDeviceCaps(hdc, DESKTOPHORZRES ); // ��ȡ��Ļ���
            return width;
        }
        finally
        {
            ReleaseDC(IntPtr.Zero, hdc);
        }
    }

    public static int GetScreenHeight()
    {
        IntPtr hdc = GetDC(IntPtr.Zero);
        if (hdc == IntPtr.Zero)
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());

        try
        {
            int height = GetDeviceCaps(hdc, DESKTOPVERTRES ); // ��ȡ��Ļ�߶�
            return height;
        }
        finally
        {
            ReleaseDC(IntPtr.Zero, hdc);
        }
    }

    // MOUSEINPUT �ṹ��
    [StructLayout(LayoutKind.Sequential)]
    public struct MOUSEINPUT
    {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    // INPUT �ṹ��
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT
    {
        public uint type;
        public MOUSEINPUT mi;
    }

    // ��������
    public const uint INPUT_MOUSE = 0;
    public const uint MOUSEEVENTF_MOVE = 0x0001;
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
    public const uint MOUSEEVENTF_ABSOLUTE = 0x8000;
    public const uint MOUSEEVENTF_VIRTUALDESK = 0x4000; // ������չ��������

    // �豸������������
    private const int HORZRES = 8;   // ˮƽ�ֱ���
    private const int VERTRES = 10;  // ��ֱ�ֱ���
    private const int LOGPIXELSX = 88;
    private const int LOGPIXELSY = 90;
    private const int DESKTOPHORZRES = 118; // ��ʵ����ֱ��ʵ�ˮƽ��С
    private const int DESKTOPVERTRES = 117; // ��ʵ����ֱ��ʵĴ�ֱ��С

    // �����Ҫ�� Windows API ����
    [DllImport("user32.dll")]
    public static extern uint SendInput(uint nInputs, [MarshalAs(UnmanagedType.LPArray), In] INPUT[] pInputs, int cbSize);

    [DllImport("user32.dll")]
    public static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("gdi32.dll")]
    public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

    [DllImport("user32.dll")]
    public static extern IntPtr GetDC(IntPtr hwnd);

    [DllImport("user32.dll")]
    public static extern int ReleaseDC(IntPtr hwnd, IntPtr hdc);

    // POINT �ṹ��
    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int X;
        public int Y;
    }
}

// POINT �ṹ����Ҫ�� C# �����ⲿҲ���壬��Ϊ GetCursorPos ʹ����
[StructLayout(LayoutKind.Sequential)]
public struct POINT
{
    public int X;
    public int Y;
}
"@

# ������Ͷ���
Add-Type -TypeDefinition $mouseScript

try {
    if ($GameName -in $programMap.Keys) {
        Start-Process -FilePath $programMap[$GameName] -Verb RunAs
    } 
    if ($GameName -in @("Arknights", "BlueArchive") ) {
        $adb = "D:\Program Files\Netease\MuMu Player 12\shell\adb.exe"
        $ip = (ipconfig | Select-String "IPv4 ��ַ" | ForEach-Object { ($_ -split ': ')[-1].Trim() })
        while ($true) {
            $output = . $adb connect 127.0.0.1:16384
            Write-Host $output
            if ($output.StartsWith("already connected") -or $output.StartsWith("connected")) {
                break
            }
            Start-Sleep -Milliseconds 1000
        }
        while ($true) {
            $output = . ${adb} -s 127.0.0.1:16384 shell settings put global http_proxy ${ip}:7890
            Write-Host $output
            if ([string]::IsNullOrEmpty($s)) {
                break
            }
            Start-Sleep -Milliseconds 1000
        }
    }
    if ($GameName -in $eventMap.Keys) {
        foreach ($event in $eventMap[$GameName]) {
            Start-Sleep -Seconds $event.delayTime
            [Mouse]::ClickAt($event.X, $event.Y)
        }
    }
}
catch [Exception] {
    Write-Error "��������: $($_.Exception.Message)"
}