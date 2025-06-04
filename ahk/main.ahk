#Requires AutoHotkey v2.0

#HotIf !WinActive("Obsidian")

/**
 * 每日待办
 */
!1:: {
    Run "obsidian://quickadd?choice=%E6%96%B0%E5%A2%9E%E6%AF%8F%E6%97%A5%E5%BE%85%E5%8A%9E%2B%E6%9C%80%E5%B0%8F%E5%8C%96"
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
    Run "obsidian://quickadd?choice=%E6%96%B0%E5%A2%9E%E9%9B%B6%E6%95%A3%E4%BF%A1%E6%81%AF%2B%E6%9C%80%E5%B0%8F%E5%8C%96"
    If !WinExist("Obsidian") {
        SendInput("!q")
    }
    Sleep 50
    WinActivate("Obsidian")
}

/**
 * 主页启动
 */
!2:: {
    If !WinExist("Obsidian") {
        SendInput("!q")
    }
    Sleep 50
    WinActivate("Obsidian")
    SendInput("!c")
}

#HotIf

#c:: {
    Run "msedge.exe"
}