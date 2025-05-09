param (
    [Parameter(Mandatory = $true, HelpMessage = "必须指定应用名称", ParameterSetName = "Default")]
    [string]$GameName,

    [Parameter(Mandatory = $false, ParameterSetName = "Help")]
    [Alias("h", "help")]
    [switch]$HelpSwitch
)

if ($HelpSwitch) {
    Write-Host "支持的游戏名称："
    foreach ($key in @( "GenshinImpact", "StarRail", "Arknights", "ZenlessZoneZero", "BlueArchive")) {
        Write-Host "- $key"
    }
    exit
}

$dataPath = "C:\Users\fumen\OneDrive\script\ClickData" # 数据存储路径
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
    // 点击指定位置
    public static void ClickAt(int x, int y)
    {
        // 移动鼠标到目标位置
        SendMouseEvent(MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE, x, y);
        
        // 模拟鼠标左键按下和释放
        SendMouseEvent(MOUSEEVENTF_LEFTDOWN, 0, 0);
        SendMouseEvent(MOUSEEVENTF_LEFTUP, 0, 0);
    }
        
    // 发送鼠标事件
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

        // 对于绝对坐标，需要将 dx 和 dy 转换为 0-65535 范围
        if ((flags & MOUSEEVENTF_ABSOLUTE) != 0)
        {
            int screenWidth = GetScreenWidth();
            int screenHeight = GetScreenHeight();

            input.mi.dx = (x * 65535) / screenWidth;
            input.mi.dy = (y * 65535) / screenHeight;

            input.mi.dwFlags |= MOUSEEVENTF_VIRTUALDESK; // 支持多显示器
        }

        uint result = SendInput(1, new INPUT[] { input }, Marshal.SizeOf(typeof(INPUT)));
        if (result == 0)
        {
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        }
    }

    
    // 获取屏幕宽度和高度
    public static int GetScreenWidth()
    {
        IntPtr hdc = GetDC(IntPtr.Zero);
        if (hdc == IntPtr.Zero)
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());

        try
        {
            int width = GetDeviceCaps(hdc, DESKTOPHORZRES ); // 获取屏幕宽度
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
            int height = GetDeviceCaps(hdc, DESKTOPVERTRES ); // 获取屏幕高度
            return height;
        }
        finally
        {
            ReleaseDC(IntPtr.Zero, hdc);
        }
    }

    // MOUSEINPUT 结构体
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

    // INPUT 结构体
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT
    {
        public uint type;
        public MOUSEINPUT mi;
    }

    // 常量定义
    public const uint INPUT_MOUSE = 0;
    public const uint MOUSEEVENTF_MOVE = 0x0001;
    public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
    public const uint MOUSEEVENTF_LEFTUP = 0x0004;
    public const uint MOUSEEVENTF_ABSOLUTE = 0x8000;
    public const uint MOUSEEVENTF_VIRTUALDESK = 0x4000; // 用于扩展绝对坐标

    // 设备能力索引常量
    private const int HORZRES = 8;   // 水平分辨率
    private const int VERTRES = 10;  // 垂直分辨率
    private const int LOGPIXELSX = 88;
    private const int LOGPIXELSY = 90;
    private const int DESKTOPHORZRES = 118; // 真实桌面分辨率的水平大小
    private const int DESKTOPVERTRES = 117; // 真实桌面分辨率的垂直大小

    // 导入必要的 Windows API 函数
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

    // POINT 结构体
    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int X;
        public int Y;
    }
}

// POINT 结构体需要在 C# 代码外部也定义，因为 GetCursorPos 使用它
[StructLayout(LayoutKind.Sequential)]
public struct POINT
{
    public int X;
    public int Y;
}
"@

# 添加类型定义
Add-Type -TypeDefinition $mouseScript

try {
    if ($GameName -in $programMap.Keys) {
        Start-Process -FilePath $programMap[$GameName] -Verb RunAs
    } 
    if ($GameName -in @("Arknights", "BlueArchive") ) {
        $adb = "D:\Program Files\Netease\MuMu Player 12\shell\adb.exe"
        $ip = (ipconfig | Select-String "IPv4 地址" | ForEach-Object { ($_ -split ': ')[-1].Trim() })
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
    Write-Error "发生错误: $($_.Exception.Message)"
}