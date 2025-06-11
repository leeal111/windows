#Requires AutoHotkey v2.0

#HotIf !WinActive("Obsidian")

/**
 * 新增待办
 */
^!1:: {
    Run "obsidian://quickadd?choice=%E6%96%B0%E5%A2%9E%E5%BE%85%E5%8A%9E%2B%E6%9C%80%E5%B0%8F%E5%8C%96"
    If !WinExist("Obsidian") {
        SendInput("!q")
    }
    Sleep 100
    WinActivate("Obsidian")
}

/**
 * 新增事件
 */
^!3:: {
    Run "obsidian://quickadd?choice=%E6%96%B0%E5%A2%9E%E4%BA%8B%E4%BB%B6%2B%E6%9C%80%E5%B0%8F%E5%8C%96"
    If !WinExist("Obsidian") {
        SendInput("!q")
    }
    Sleep 100
    WinActivate("Obsidian")
}
#HotIf

#c:: {
    Run "msedge.exe"
}