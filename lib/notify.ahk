class Notify {
    _pending := []
    _active := []
    _max := 5
    _level := 1
    _style := "slide"
    _loopActive := false
    _config := ""

    Init(config) {
        this._config := config
        this._max := config.Get("Notify", "Max", 5)
        this._level := config.Get("Notify", "MsgLevel", 1)
        this._style := config.Get("Notify", "Style", "slide")
        if config.Get("Notify", "Enable", 1) = 1
            this._StartLoop()
    }

    Error(msg, extra := "") {
        errMsg := msg
        if extra
            errMsg .= "`n`n" . extra
        MsgBox(errMsg, "Capslock2 Error", 16)
    }

    Warn(msg) => this.Push(msg, "WARNING", 6000, 2)
    Info(msg) => this.Push(msg, "INFO", 3000, 1)
    Debug(msg) => this.Push(msg, "DEBUG", 3000, 0)

    Push(msg, title := "INFO", delay := 3000, level := 1) {
        if level < this._level
            return
        if A_IsSuspended
            return
        this._pending.InsertAt(1, {msg: msg, title: title, delay: delay})
    }

    SetLevel(n) {
        this._level := n
    }

    _StartLoop() {
        if this._loopActive
            return
        this._loopActive := true
        SetTimer(this._Consume.Bind(this), 250)
    }

    _Consume() {
        if this._config.Get("Basic", "DisableOnFullScreen", 1) = 1 {
            if WindowMgr.IsFullScreen("A") and not WindowMgr.IsDesktop("A")
                return
        }
        if this._pending.Length = 0 and this._active.Length = 0
            return
        while this._pending.Length > 0 {
            item := this._pending.Pop()
            this._Show(item.msg, item.title, item.delay)
        }
        this._TickCountdown()
        this._CheckExpired()
    }

    _Show(message, title, delay) {
        ; enforce max notification limit
        while this._active.Length >= this._max {
            oldest := this._active.Pop()
            oldest.gui.Destroy()
        }

        gui := this._BuildGui(message, title)
        pos := this._GetPosition(gui, 400)
        Width := pos.w, Height := pos.h

        for _, item in this._active {
            item.y -= Height
            item.gui.Show("NoActivate NA y" . item.y)
        }

        x := pos.x, y := pos.y
        gui.Show("W" . Width . " H" . Height . " NoActivate Hide x" . x . " y" . y)
        WinSetRegion("0-0 w" . Width . " h" . Height . " r6-6")

        if (this._style = "slide")
            this._Animate(gui.Hwnd, "slide_in")
        else if (this._style = "fade")
            this._Animate(gui.Hwnd, "fade_in")

        this._active.InsertAt(1, {gui: gui, y: y, h: Height, counter: delay})
    }

    _BuildGui(message, title, Width := 400) {
        gui := Gui()
        gui.Opt("+AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound -DPIScale")
        gui.BackColor := "c808080"
        gui.MarginX := 0
        gui.MarginY := 10
        gui.SetFont("s13 cD0D0D0", "Bold")
        gui.Add("Progress", "x-1 y-1 w" . (Width + 2) . " h31 Background404040 Disabled")
        gui.Add("Text", "x0 y0 w" . Width . " h30 BackgroundTrans Center 0x200", title)
        gui.SetFont("s10")
        gui.Add("Text", "x7 y+10 Center w" . (Width - 14), message)
        return gui
    }

    _GetPosition(gui, W) {
        gui.Show("NoActivate Hide W" . W)
        WinGetPos(&x, &y, &w, &h)
        MonitorGetWorkArea(,,, &right, &bottom)
        return {x: right - w - 5, y: bottom - h - 5, w: w, h: h}
    }

    _Animate(hwnd, method) {
        if (method = "slide_in")
            value := 0x40002
        else if (method = "slide_out")
            value := 0x50001
        else if (method = "fade_in")
            value := 0xA0000
        else
            value := 0x90000
        DllCall("AnimateWindow", "UInt", hwnd, "Int", 300, "UInt", value)
    }

    _TickCountdown() {
        for i, item in this._active
            this._active[i].counter := Max(item.counter - 250, 0)
    }

    _CheckExpired() {
        reversed := Helpers.GetReverseArray(this._active)
        for _, item in reversed {
            if item.counter <= 0 {
                hwnd := item.gui.Hwnd
                if (this._style = "slide")
                    this._Animate(hwnd, "slide_out")
                else if (this._style = "fade")
                    this._Animate(hwnd, "fade_out")
                item.gui.Destroy()
                for i, a in this._active {
                    if a.gui.Hwnd = hwnd {
                        this._active.RemoveAt(i)
                        break
                    }
                }
            }
        }
    }
}
