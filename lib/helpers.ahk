class Helpers {
    ; === HTTP ===
    static Get(url, headers := "", proxy := "", timeout := 500) {
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", url, false)
            whr.SetTimeouts(0, timeout, timeout, timeout)
            if proxy
                whr.SetProxy(2, proxy)
            if IsObject(headers)
                for key, value in headers
                    whr.SetRequestHeader(key, value)
            whr.Send()
            return whr.ResponseText
        }
        catch
            return ""
    }

    ; === Proxy ===
    static PROXY_KEY := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    static GetProxyStatus() {
        return RegRead(Helpers.PROXY_KEY, "ProxyEnable", 0)
    }

    static GetProxyServer() {
        return RegRead(Helpers.PROXY_KEY, "ProxyServer", "localhost:1234")
    }

    static SetProxy(enable, server := "") {
        if (server != "" and Helpers.GetProxyServer() != server)
            RegWrite(server, "REG_SZ", Helpers.PROXY_KEY, "ProxyServer")
        if (Helpers.GetProxyStatus() != enable)
            RegWrite(enable, "REG_DWORD", Helpers.PROXY_KEY, "ProxyEnable")
        Helpers.RefreshProxy()
    }

    static ToggleProxy(*) {
        Helpers.SetProxy(Helpers.GetProxyStatus() = 1 ? 0 : 1)
    }

    static RefreshProxy() {
        DllCall("Wininet\InternetSetOptionW", "int", 0, "int", 37, "int", 0, "int", 0)
        DllCall("Wininet\InternetSetOptionW", "int", 0, "int", 39, "int", 0, "int", 0)
    }

    ; === Clipboard ===
    static GetSelectedText() {
        ClipboardOld := ClipboardAll()
        A_Clipboard := ""
        SendInput("^{Insert}")
        ClipWait(0.05)
        selText := A_Clipboard
        A_Clipboard := ClipboardOld
        return selText
    }

    ; === Background process ===
    static ToggleBackground(name, cmd) {
        bg_exe := Helpers.GetNameFromCmd(cmd)
        pid := ProcessExist(bg_exe)
        if (pid = 0) {
            Helpers.RunBackgroundCommand(cmd)
            return "started"
        } else {
            ProcessClose(pid)
            return "killed"
        }
    }

    static GetNameFromCmd(cmd) {
        path := SubStr(cmd, 1, 1) = '"' ? StrSplit(SubStr(cmd, 2), '"')[1] : StrSplit(cmd, " ")[1]
        return StrSplit(path, ["\", "/"])[-1]
    }

    static RunBackgroundCommand(cmd) {
        shell := ComObject("WScript.Shell")
        shell.Run(cmd, 0)
    }

    ; === String / text ===
    static PunctTrim(word) {
        return Trim(word, "!`"#$%&'()*+,-./:;<=>?@[\]^_``{|}~ ！？。，‘`"'：；、")
    }

    ; === UI ===
    static OnMouseToolTip(msg, delay := 1000) {
        MouseGetPos(&X, &Y)
        ToolTip(msg, X - 5, Y - 5)
        SetTimer(_ToolTipCheck, delay)
        _ToolTipCheck() {
            MouseGetPos(,, &Win)
            if WinExist("ahk_class tooltips_class32") != Win {
                ToolTip()
            } else {
                SetTimer(_ToolTipCheck, 0)
                SetTimer(_ToolTipCheck, delay)
            }
        }
    }
}
