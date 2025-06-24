ClickWindow(G_game, G_game_clickEvent) {
    Run G_game
    WinWait(G_game_clickEvent[1].title)
    Sleep(1000) ; 安全冗余
    for event in G_game_clickEvent {
        if WinExist(event.title) {
            WinActivate(event.title)
            ; 等待窗口激活
            WinWaitActive(event.title)
            ; 移动鼠标到指定坐标并点击
            MouseMove(event.x, event.y)
            Click("Left")
            Sleep(1000)
        } else {
            MsgBox("未找到窗口: " . event.title)
        }
    }
}