#Requires AutoHotkey v2.0

#HotIf !WinActive("Obsidian")

/**
 * 每日待办
 */
!1:: {
    Run "obsidian://quickadd?choice=%E6%96%B0%E5%A2%9E%E6%AF%8F%E6%97%A5%E5%BE%85%E5%8A%9E"
    If !WinExist("Obsidian") {
        SendInput("!q")
    }
    Sleep 50
    WinActivate("Obsidian")
}

/**
 * 零碎记录
 */
!3:: {
    Run "obsidian://quickadd?choice=%E6%96%B0%E5%A2%9E%E9%9B%B6%E7%A2%8E%E7%89%87%E6%AE%B5"
    If !WinExist("Obsidian") {
        SendInput("!q")
    }
    Sleep 50
    WinActivate("Obsidian")
}

#c:: {
    Run "msedge.exe"
}
#HotIf