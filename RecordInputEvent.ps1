# 描述: 用于记录鼠标和键盘输入事件

param (
    [Parameter(Mandatory = $true, HelpMessage = "必须指定事件名称")]
    [string]$EventName
)


$dataPath = "C:\Users\fumen\OneDrive\script\ClickData" # 数据存储路径

$eventScript = @"
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class EventHook
{
    private delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);
    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    // 存储鼠标点击事件的列表
    private static List<MouseClickEvent> _mouseClickEvents = new List<MouseClickEvent>();

    private static long _startTimestamp = GetUnixTimestampSeconds();
    private static bool _flag = false;

    private static IntPtr MouseHookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0)
        {
            int wParamInt = wParam.ToInt32();
            if (wParamInt == WM_LBUTTONDOWN)
            {
                MSLLHOOKSTRUCT hookStruct = (MSLLHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(MSLLHOOKSTRUCT));
                MouseClickEvent clickEvent = new MouseClickEvent
                {
                    X = hookStruct.pt.x,
                    Y = hookStruct.pt.y,
                    delayTime = GetUnixTimestampSeconds()-_startTimestamp // 使用 Unix 时间戳（秒）
                };
                _startTimestamp = GetUnixTimestampSeconds(); // 更新开始时间戳
                
                // 将鼠标点击事件添加到列表中
                if (_flag)
                {
                    // 如果 _flag 为 true，则添加事件到列表
                    Console.WriteLine("Add: Mouse Click: X=" + clickEvent.X + ", Y=" + clickEvent.Y + ", delayTime=" + clickEvent.delayTime);
                    _mouseClickEvents.Add(clickEvent);
                }
                else
                {
                    // 如果 _flag 为 false，则不添加事件到列表
                    Console.WriteLine("Mouse Click: X=" + clickEvent.X + ", Y=" + clickEvent.Y + ", delayTime=" + clickEvent.delayTime);
                }
            }
        }
        return CallNextHookEx(_mouseHookID, nCode, wParam, lParam);
    }

    private static IntPtr KeyboardHookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN)
        {
            KBDLLHOOKSTRUCT hookStruct = (KBDLLHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(KBDLLHOOKSTRUCT));
            Console.WriteLine("Key pressed: "+hookStruct.vkCode); // 添加日志输出，便于调试
            if ((Control.ModifierKeys & Keys.Control) == Keys.Control &&
            (Control.ModifierKeys & Keys.Alt) == Keys.Alt &&
            hookStruct.vkCode == (uint)Keys.Q)
            {
                Console.WriteLine("Ctrl+Alt+C pressed, stopping...");
                Stop();
            }
            if ((Control.ModifierKeys & Keys.Control) == Keys.Control &&
            (Control.ModifierKeys & Keys.Alt) == Keys.Alt &&
            hookStruct.vkCode == (uint)Keys.W)
            {
                _flag = true;
            }
            if ((Control.ModifierKeys & Keys.Control) == Keys.Control &&
            (Control.ModifierKeys & Keys.Alt) == Keys.Alt &&
            hookStruct.vkCode == (uint)Keys.E)
            {
                _flag = false;
            }
        }
        return CallNextHookEx(_keyboardHookID, nCode, wParam, lParam);
    }

    private static LowLevelMouseProc _mouseProc = MouseHookCallback;
    private static LowLevelKeyboardProc _keyboardProc = KeyboardHookCallback;

    private static IntPtr _mouseHookID = IntPtr.Zero;
    private static IntPtr _keyboardHookID = IntPtr.Zero;

    public static void Start()
    {
        using (var curProcess = System.Diagnostics.Process.GetCurrentProcess())
        using (var curModule = curProcess.MainModule)
        {
            _mouseHookID = SetWindowsHookEx(WH_MOUSE_LL, _mouseProc, GetModuleHandle(curModule.ModuleName), 0);
            _keyboardHookID = SetWindowsHookEx(WH_KEYBOARD_LL, _keyboardProc, GetModuleHandle(curModule.ModuleName), 0);
        }
        Application.Run();
    }

    public static void Stop()
    {
        // 将鼠标点击事件保存为 JSON 文件
        string json = ConvertMouseClickEventsToJson(_mouseClickEvents);
        string logFilePath = Environment.GetEnvironmentVariable("EventPath"); // 从环境变量获取路径
        if(_mouseClickEvents.Count != 0)
        {
            File.WriteAllText(logFilePath, json);
        }
        Console.WriteLine("Mouse click events saved to " + logFilePath + ". Total events: " + _mouseClickEvents.Count.ToString());
        _mouseClickEvents.Clear(); // 清空事件列表

        UnhookWindowsHookEx(_mouseHookID);
        UnhookWindowsHookEx(_keyboardHookID);
        Application.Exit();
    }

    // 鼠标点击事件数据结构
    private class MouseClickEvent
    {
        public int X { get; set; }
        public int Y { get; set; }
        public long delayTime { get; set; } // 改为 long 类型存储 Unix 时间戳（秒）
    }

    private const int WH_MOUSE_LL = 14;
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_LBUTTONDOWN = 0x0201;
    private const int WM_KEYDOWN = 0x0100;

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    [StructLayout(LayoutKind.Sequential)]
    private struct POINT
    {
        public int x;
        public int y;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MSLLHOOKSTRUCT
    {
        public POINT pt;
        public uint mouseData;
        public uint flags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct KBDLLHOOKSTRUCT
    {
        public uint vkCode;
        public uint scanCode;
        public uint flags;
        public uint time;
        public IntPtr dwExtraInfo;
    }

    // 获取当前 Unix 时间戳（秒）
    private static long GetUnixTimestampSeconds()
    {
        DateTimeOffset now = DateTimeOffset.UtcNow;
        return now.ToUnixTimeSeconds();
    }

    // 将 MouseClickEvent 列表转换为 JSON 字符串
    private static string ConvertMouseClickEventsToJson(List<MouseClickEvent> events)
    {
        // 手动构建 JSON 字符串
        var json = new System.Text.StringBuilder();

        // 开始构建 JSON 数组
        json.Append("[");

        // 用于判断是否为第一个元素
        bool isFirst = true;

        foreach (var clickEvent in events)
        {
            if (!isFirst)
            {
                json.Append(",");
            }
            else
            {
                isFirst = false;
            }

            // 构建 JSON 对象
            json.Append("{\"X\":" + clickEvent.X + ",\"Y\":" + clickEvent.Y + ",\"delayTime\":" + clickEvent.delayTime + "}");
        }

        // 结束 JSON 数组
        json.Append("]");

        return json.ToString();
    }
}
"@

$env:EventPath = Join-Path -Path $dataPath -ChildPath $EventName".json"

if (Test-Path -Path $env:EventPath) {
    Write-Error "File exists: $env:EventPath"
    exit
}

Add-Type -TypeDefinition $eventScript -ReferencedAssemblies @(
    'System.Windows.Forms'
)

[EventHook]::Start()