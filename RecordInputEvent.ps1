# ����: ���ڼ�¼���ͼ��������¼�

param (
    [Parameter(Mandatory = $true, HelpMessage = "����ָ���¼�����")]
    [string]$EventName
)


$dataPath = "C:\Users\fumen\OneDrive\script\ClickData" # ���ݴ洢·��

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

    // �洢������¼����б�
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
                    delayTime = GetUnixTimestampSeconds()-_startTimestamp // ʹ�� Unix ʱ������룩
                };
                _startTimestamp = GetUnixTimestampSeconds(); // ���¿�ʼʱ���
                
                // ��������¼���ӵ��б���
                if (_flag)
                {
                    // ��� _flag Ϊ true��������¼����б�
                    Console.WriteLine("Add: Mouse Click: X=" + clickEvent.X + ", Y=" + clickEvent.Y + ", delayTime=" + clickEvent.delayTime);
                    _mouseClickEvents.Add(clickEvent);
                }
                else
                {
                    // ��� _flag Ϊ false��������¼����б�
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
            Console.WriteLine("Key pressed: "+hookStruct.vkCode); // �����־��������ڵ���
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
        // ��������¼�����Ϊ JSON �ļ�
        string json = ConvertMouseClickEventsToJson(_mouseClickEvents);
        string logFilePath = Environment.GetEnvironmentVariable("EventPath"); // �ӻ���������ȡ·��
        if(_mouseClickEvents.Count != 0)
        {
            File.WriteAllText(logFilePath, json);
        }
        Console.WriteLine("Mouse click events saved to " + logFilePath + ". Total events: " + _mouseClickEvents.Count.ToString());
        _mouseClickEvents.Clear(); // ����¼��б�

        UnhookWindowsHookEx(_mouseHookID);
        UnhookWindowsHookEx(_keyboardHookID);
        Application.Exit();
    }

    // ������¼����ݽṹ
    private class MouseClickEvent
    {
        public int X { get; set; }
        public int Y { get; set; }
        public long delayTime { get; set; } // ��Ϊ long ���ʹ洢 Unix ʱ������룩
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

    // ��ȡ��ǰ Unix ʱ������룩
    private static long GetUnixTimestampSeconds()
    {
        DateTimeOffset now = DateTimeOffset.UtcNow;
        return now.ToUnixTimeSeconds();
    }

    // �� MouseClickEvent �б�ת��Ϊ JSON �ַ���
    private static string ConvertMouseClickEventsToJson(List<MouseClickEvent> events)
    {
        // �ֶ����� JSON �ַ���
        var json = new System.Text.StringBuilder();

        // ��ʼ���� JSON ����
        json.Append("[");

        // �����ж��Ƿ�Ϊ��һ��Ԫ��
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

            // ���� JSON ����
            json.Append("{\"X\":" + clickEvent.X + ",\"Y\":" + clickEvent.Y + ",\"delayTime\":" + clickEvent.delayTime + "}");
        }

        // ���� JSON ����
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