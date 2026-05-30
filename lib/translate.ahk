class TranslateSvc {
    _srcLang := "en"
    _dstLang := "zh-CN"
    _apiKey := ""

    ; Result GUI
    _resultGui := ""

    __New(config) {
        this._srcLang := config.Get("Trans", "SourceLanguage", "en")
        this._dstLang := config.Get("Trans", "TargetLanguage", "zh-CN")
        this._apiKey := config.Get("Trans", "MyMemoryKey", "")
    }

    TranslateSelected() {
        content := Helpers.GetSelectedText()
        if (content = "") {
            Engine.Instance.notify.Info("No text selected")
            return
        }
        text := Helpers.PunctTrim(content)
        if (text = "")
            return

        Engine.Instance.notify.Info("Translating...")
        result := this._Translate(text)
        this._ShowResult(result)
    }

    _Translate(text) {
        src := this._srcLang = "auto" ? "en" : this._srcLang
        dst := this._dstLang = "zh" ? "zh-CN" : this._dstLang
        url := "https://api.mymemory.translated.net/get?q=" . text
            . "&langpair=" . src . "|" . dst
            . (this._apiKey != "" ? (InStr(this._apiKey, "@") ? "&de=" : "&key=") . this._apiKey : "")

        proxy := this._GetProxy()
        header := Map(
            "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        )
        response := Helpers.Get(url, header, proxy)
        try {
            jsonObj := Jxon_Load(&response)
            return jsonObj["responseData"]["translatedText"]
        }
        catch Error as e {
            return "Translate failed: " . e.Message
        }
    }

    _GetProxy() {
        mode := Engine.Instance.config.Get("Basic", "Proxy", "")
        if (mode = "system" and Helpers.GetProxyStatus())
            return Helpers.GetProxyServer()
        else if (mode = "force")
            return Helpers.GetProxyServer()
        return ""
    }

    _ShowResult(text) {
        if this._resultGui != ""
            this._resultGui.Destroy()

        ; Width by content length, capped at 70% screen
        maxChars := 0
        for line in StrSplit(text, "`n", "`r") {
            n := StrLen(line)
            if n > maxChars
                maxChars := n
        }
        editW := Min(Max(maxChars * 14 + 50, 320), Floor(A_ScreenWidth * 0.7))

        ; Height from estimated wrapped lines given edit width
        charsPerLine := Max(Floor(editW / 14), 1)
        totalLines := 0
        for line in StrSplit(text, "`n", "`r")
            totalLines += Max(Ceil(StrLen(line) / charsPerLine), 1)
        editRows := Min(totalLines + 2, 14)

        g := Gui()
        g.Opt("+AlwaysOnTop +ToolWindow -SysMenu -Caption -DPIScale")
        g.BackColor := "c282828"
        g.MarginX := 16
        g.MarginY := 14
        g.OnEvent("Escape", (*) => this._Dismiss())

        ; Header bar — draggable (leaves 100px right margin for buttons)
        g.SetFont("s8 cC0C0C0", "Segoe UI")
        dragBar := g.Add("Text", Format("x16 y16 w{} h24", editW - 100), "TRANSLATION")
        dragBar.OnEvent("Click", (*) => PostMessage(0xA1, 2, 0, , g.Hwnd))

        ; Copy button
        g.SetFont("s8 c808080", "Segoe UI")
        copyBtn := g.Add("Text", Format("x{} y17 +0x200", editW - 76), "COPY")
        copyBtn.OnEvent("Click", (*) => this._CopyResult(copyBtn))

        ; Close button
        g.SetFont("s10 c808080", "Segoe UI")
        closeBtn := g.Add("Text", Format("x{} y14 +0x200", editW + 4), Chr(0x2715))
        closeBtn.OnEvent("Click", (*) => this._Dismiss())

        ; Translated text
        g.SetFont("s12 cFFFFFF", "Segoe UI")
        g.Add("Edit", Format("ReadOnly -E0x200 +Wrap -HScroll -VScroll x16 y46 w{} r{} +Backgroundc282828", editW, editRows), text)

        g.Show("NoActivate Hide")
        WinGetPos(, , &w, &h, g)

        MouseGetPos(&mx, &my)
        MonitorGetWorkArea(, , , &right, &bottom)
        x := Min(Max(mx - w // 2, 0), right - w)
        y := Max(my - h - 20, 0)
        g.Show("NoActivate x" . x . " y" . y)
        WinSetRegion("0-0 w" . w . " h" . h . " r8-8", g.Hwnd)

        this._resultGui := g
        this._resultText := text
    }

    _CopyResult(btn) {
        A_Clipboard := this._resultText
        btn.Opt("c4A90D9")
        SetTimer((*) => btn.Opt("c808080"), -800)
    }

    _Dismiss() {
        if this._resultGui != "" {
            this._resultGui.Destroy()
            this._resultGui := ""
        }
    }
}
