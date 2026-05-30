class WindowMgr {
    _quick := Map()

    ActivateOrLaunch(path) {
        ; Build window title and launch path from [Switch] value.
        ; "notepad.exe"  →  title="ahk_exe notepad.exe"  exe="notepad.exe"
        ; "app.exe ahk_exe app.exe ahk_class XXX"
        ;   →  title="ahk_exe app.exe ahk_class XXX"  exe="app.exe"
        ; "C:\...\app.exe ahk_exe app.exe ahk_class XXX"
        ;   →  title="ahk_exe app.exe ahk_class XXX"  exe="C:\...\app.exe"
        ahkPos := InStr(path, "ahk_")
        if ahkPos {
            title := SubStr(path, ahkPos)
            exe := Trim(SubStr(path, 1, ahkPos - 1))
        } else {
            exe := path
            if InStr(exe, "\")
                SplitPath(path, &exe)
            title := "ahk_exe " . exe
        }

        hwnd := WinExist(title)
        if not hwnd {
            Run(exe)
        } else if not WinActive("ahk_id " . hwnd) {
            WinActivate("ahk_id " . hwnd)
        } else {
            WinMinimize()
        }
    }

    QWindowToggle(idx) {
        hwnd := this._quick.Get(idx, 0)
        if (hwnd = 0)
            return "not_bound"
        if not WinExist(hwnd) {
            this._quick[idx] := 0
            return "closed"
        }
        if WinActive(hwnd) {
            WinMinimize()
            return "minimized"
        }
        WinActivate(hwnd)
        return "activated"
    }

    QWindowBind(idx) {
        hwnd := WinGetID("A")
        exe := WinGetProcessName("A")
        cls := WinGetClass("A")
        if (exe = "Explorer.EXE" and cls = "WorkerW")
            return ""
        this._quick[idx] := hwnd
        return WinGetTitle(hwnd)
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
        title := "ahk_class " . cls . " ahk_exe " . exe
        cur := WinGetID("A")
        hwnds := WinGetList(title)
        for hwnd in hwnds {
            if hwnd = cur
                continue
            if not DllCall("IsWindowVisible", "Ptr", hwnd)
                continue
            if WinGetMinMax(hwnd) = -1
                continue
            WinActivate("ahk_id " . hwnd)
            return
        }
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
