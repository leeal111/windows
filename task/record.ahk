; 左键点击时获取鼠标相对于指定窗口的坐标

global flag := false

~LButton::
{
    ; 获取鼠标的屏幕相对坐标
    if (flag) {
        MouseGetPos(&MouseX, &MouseY, &TargetWindow)
        WindowTitle := WinGetTitle("ahk_id " TargetWindow)
        MsgBox("鼠标的坐标：X=" . MouseX . ", Y=" . MouseY . "`n窗口标题：" . WindowTitle)
    }
}

; F1键切换flag状态
F1::
{
    global flag
    flag := !flag
}

; Ctrl+Escape退出脚本
^Escape::
{
    ExitApp
}