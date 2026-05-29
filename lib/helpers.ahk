class Helpers {
    ; === HTTP ===
    static Get(url, headers := "", proxy := "", timeout := 500) {
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", url, false)
            whr.SetTimeouts(0, timeout, timeout, timeout)
            if proxy
                whr.SetProxy(2, proxy)
            if (headers != "")
                for key, value in headers
                    whr.SetRequestHeader(key, value)
            whr.Send()
            return whr.ResponseText
        }
        catch
            return ""
    }

    static Post(url, body, headers := "", proxy := "", timeout := 500) {
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("POST", url, false)
            whr.SetTimeouts(0, timeout, timeout, timeout)
            if proxy
                whr.SetProxy(2, proxy)
            if (headers != "")
                for key, value in headers
                    whr.SetRequestHeader(key, value)
            whr.Send(body)
            return whr.ResponseText
        }
        catch
            return ""
    }

    ; === Proxy ===
    static GetProxyStatus() {
        return RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable", 0)
    }

    static GetProxyServer() {
        default := "localhost:1234"
        return RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer", default)
    }

    static SetProxy(enable, server := "") {
        if (server != "" and Helpers.GetProxyServer() != server) {
            RegWrite(server, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer")
        }
        if (Helpers.GetProxyStatus() != enable) {
            RegWrite(enable, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
        }
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

    static GetLastWord() {
        selText := Helpers.GetSelectedText()
        selText := Helpers.PunctTrim(selText)
        if (selText != "") {
            words := StrSplit(selText, [",", ".", " ", "，", "。"])
            return words[words.Length]
        }
        return ""
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
        path := StrSplit(cmd, " ")[1]
        name := StrSplit(path, ["\", "/"])[-1]
        return name
    }

    static RunBackgroundCommand(cmd) {
        shell := ComObject("WScript.Shell")
        shell.Run(cmd, 0)
    }

    ; === Python ===
    static RunPythonCode(code, pythonPath) {
        if (pythonPath = "")
            return "Python not configured"
        Script := A_ScriptDir . "\lib\pyrunner.py"
        tempOutput := A_Temp . "\temp_output_" . A_TickCount . ".txt"
        cmd := pythonPath . " " . Script . " " . tempOutput
        shell := ComObject("WScript.Shell")
        exec := shell.Exec(cmd)
        exec.StdIn.Write(code)
        exec.StdIn.Close()
        exec.Status  ; wait for completion
        if FileExist(tempOutput) {
            try {
                output := FileRead(tempOutput, "UTF-8")
                FileDelete(tempOutput)
                return output
            }
            catch
                return "Failed to read output"
        }
        return "Execution failed"
    }

    ; === String / text ===
    static PunctTrim(word) {
        return Trim(word, "!`"#$%&'()*+,-./:;<=>?@[\]^_``{|}~ ！？。，‘"’"：；、")
    }

    static StrType(s) {
        s := Helpers.PunctTrim(s)
        return RegExMatch(s, "^ *[a-zA-Z]* *$") ? "word" : "sentence"
    }

    static RegExFindAll(haystack, needle) {
        result := []
        pos := 1
        while (pos := RegExMatch(haystack, needle, &match, pos)) {
            pos += StrLen(match[])
            result.Push(match[])
        }
        return result
    }

    static CountSubStr(haystack, needle) {
        return Helpers.RegExFindAll(haystack, needle).Length
    }

    static GetReverseArray(arr) {
        rarr := []
        for value in arr
            rarr.InsertAt(1, value)
        return rarr
    }

    static ArrayToString(arr, dilim := " ") {
        str := ""
        for i, v in arr
            str .= (i > 1 ? dilim : "") . v
        return str
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

    ; === Window ===
    static CheckIfCaretNotDetectable() {
        NumMonitors := SysGet(80)
        if (NumMonitors < 1)
            NumMonitors := 1
        CaretGetPos(&CaretX)
        if (CaretX != 0)
            return 1
        Loop NumMonitors {
            MonitorGet(A_Index, &left)
            if (CaretX = left)
                return 1
        }
        return 0
    }

    static InputSingleKey() {
        ih := InputHook("T3 L1")
        ih.Start()
        ih.Wait()
        return ih.Input
    }
}
