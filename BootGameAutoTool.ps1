param (
    [ValidateSet("GenshinImpact", "StarRail", "Arknights", "ZenlessZoneZero", "BlueArchive")]
    [string]$GameName
)

# 创建哈希表
$eventMap = @{
    GenshinImpact   = @{
        path   = "D:\PortableDir\BetterGI_v0.42.0\BetterGI.exe"
        events = @(
            @{
                X         = 912
                Y         = 622
                delayTime = 10000
            },
            @{
                X         = 932
                Y         = 660
                delayTime = 1000
            }
            ,
            @{
                X         = 1067
                Y         = 924
                delayTime = 1000
            },
            @{
                X         = 1212
                Y         = 513
                delayTime = 1000
            },
            @{
                X         = 1233
                Y         = 839
                delayTime = 1000
            },
            @{
                X         = 365
                Y         = 752
                delayTime = 1000
            }
        )
    }
    StarRail        = @{
        path   = "D:\PortableDir\March7thAssistant_v2024.12.18_full\March7th Launcher.exe"
        events = @(
            @{
                X         = 961
                Y         = 833
                delayTime = 10000
            }
        )
    }
    Arknights       = @{
        path   = "D:\PortableDir\MAA-v5.11.1-win-x64\MAA.exe"
        events = @(
        )
    }
    ZenlessZoneZero = @{
        path   = "D:\PortableDir\ZenlessZoneZero-OneDragon\OneDragon Launcher.exe"
        events = @(
            @{
                X         = 133
                Y         = 254
                delayTime = 10000
            }

            @{
                X         = 710
                Y         = 450
                delayTime = 1000
            }        
        )
    }
    BlueArchive     = @{
        path   = "D:\PortableDir\BlueArchiveAutoScript_v1_2_0_x86_64\BlueArchiveAutoScript_v1_2_0_x86_64.exe"
        events = @(
            @{
                X         = 851
                Y         = 846
                delayTime = 2 * 60000
            }
            @{
                X         = 1186
                Y         = 575
                delayTime = 1000
            }
        )
    }
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
            return GetDeviceCaps(hdc, HORZRES);
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
            return GetDeviceCaps(hdc, VERTRES);
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
    $map = $eventMap[$GameName]
    Start-Process -FilePath $map["path"] -Verb RunAs
    foreach ($event in $map["events"]) {
        Start-Sleep -Milliseconds $event.delayTime
        [Mouse]::ClickAt($event.X, $event.Y)
    }
}
catch [Exception] {
    Write-Error "发生错误: $($_.Exception.Message)"
}