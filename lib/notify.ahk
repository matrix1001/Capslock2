class Notify {
    _level := 1

    Init(config) {
        this._level := config.Get("Notify", "MsgLevel", 1)
    }

    Error(msg, extra := "") {
        errMsg := msg
        if extra
            errMsg .= "`n`n" . extra
        MsgBox(errMsg, "Capslock2 Error", 16)
    }

    Warn(msg) {
        if this._level <= 2
            this._Show(msg, 6000)
    }

    Info(msg) {
        if this._level <= 1
            this._Show(msg, 3000)
    }

    Debug(msg) {
        if this._level <= 0
            this._Show(msg, 3000)
    }

    SetLevel(n) {
        this._level := n
    }

    _Show(msg, timeout) {
        static g := ""
        if g != ""
            g.Destroy()
        MonitorGetWorkArea(, , , &right, &bottom)
        g := Gui()
        g.Opt("+AlwaysOnTop +ToolWindow -SysMenu -Caption -DPIScale")
        g.BackColor := "c282828"
        g.MarginX := 18
        g.MarginY := 10
        g.SetFont("s9 c808080", "Segoe UI")
        g.Add("Text", , "CAPSLOCK2")
        g.SetFont("s14 cFFFFFF", "Segoe UI")
        g.Add("Text", , msg)
        g.Show("NoActivate Hide")
        WinGetPos(, , &w, &h, g)
        g.Show("NoActivate x" . (right - w - 10) . " y" . (bottom - h - 10))
        WinSetRegion("0-0 w" . w . " h" . h . " r8-8", g.Hwnd)
        SetTimer(g.Destroy.Bind(g), -timeout)
    }
}
