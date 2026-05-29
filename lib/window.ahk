class WindowMgr {
    _quick := Map()

    ActivateOrLaunch(path) {
        title := "ahk_exe " . path
        if not WinExist(title) {
            Run(path)
        } else if not WinActive(title) {
            WinActivate(title)
        } else {
            WinMinimize()
        }
    }

    ActivateOrLaunchLast(path) {
        title := "ahk_exe " . path
        if not WinExist(title) {
            Run(path)
        } else if not WinActive(title) {
            WinActivateBottom(title)
        } else {
            WinMinimize()
        }
    }

    QuickToggle(idx) {
        hwnd := this._quick.Get(idx, 0)
        if (hwnd != 0) {
            if not WinExist(hwnd) {
                this._quick[idx] := 0
                return
            }
            if WinActive(hwnd)
                WinMinimize()
            else
                WinActivate(hwnd)
        } else {
            this.QuickBind(idx)
        }
    }

    QuickBind(idx) {
        hwnd := WinGetID("A")
        exe := WinGetProcessName("A")
        cls := WinGetClass("A")
        if (exe = "Explorer.EXE" and cls = "WorkerW")
            return
        this._quick[idx] := hwnd
    }

    QuickClear(idx) {
        this._quick[idx] := 0
    }

    KillActive() {
        WinKill(WinGetID("A"))
    }

    ToggleAlwaysOnTop() {
        WinSetAlwaysOnTop(-1, "A")
        ExStyle := WinGetExStyle("A")
        return (ExStyle & 0x8) ? true : false
    }

    SameProcessSwitch() {
        cls := WinGetClass("A")
        exe := WinGetProcessPath("A")
        WinActivateBottom("ahk_class " . cls . " ahk_exe " . exe)
    }

    static IsFullScreen(winTitle) {
        winID := WinExist(winTitle)
        if not winID
            return false
        style := WinGetStyle(winID)
        WinGetPos(,, &winW, &winH, winID)
        return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
    }

    static IsDesktop(winTitle) {
        cls := WinGetClass(winTitle)
        name := WinGetProcessName(winTitle)
        return (cls = "WorkerW" or cls = "Progman") and (name = "Explorer.EXE" or name = "explorer.exe")
    }

    static MouseIsOver(winTitle) {
        MouseGetPos(,, &Win)
        return WinExist(winTitle) = Win
    }
}
