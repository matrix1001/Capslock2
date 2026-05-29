;----func
RunFunc(fn_str, threaded := 0)
{
    match := []
    params := []
    if (!RegExMatch(Trim(fn_str), "\)$"))
        fn := %fn_str%
    else if (RegExMatch(fn_str, "(\w+)\((.*)\)$", &match))
    {
        fn := %match[1]%
        if (match.Count > 1)
            params := StrSplit(match[2], ",", " `"`'")
    }
    else
        return
    if (threaded = 0)
        return fn(params*)
    SetTimer(FnWithParams, -1)
    FnWithParams()
    {
        fn(params*)
    }
}

RunBackgroudCommand(cmd)
{
    shell := ComObject("WScript.Shell")
    shell.Run(cmd, 0)
}

;--------IO function
ListFiles(dir)
{
    lst := []
    Loop Files, dir . "\*", "F"
        lst.Push(dir . "\" . A_LoopFileName)
    return lst
}

GetSelectedText()
{
    ClipboardOld := ClipboardAll()
    A_Clipboard := ""
    SendInput("^{insert}")
    ClipWait(0.05)
    selText := A_Clipboard
    A_Clipboard := ClipboardOld
    return selText
}

GetLastWord()
{
    selText := GetSelectedText()
    selText := PunctTrim(selText)
    if (selText != "")
    {
        words := StrSplit(selText, [",","."," ","，","。"])
        return words[words.Length]
    }
    return ""
}

InputSingleKey()
{
    ih := InputHook("T3 L1")
    ih.Start()
    ih.Wait()
    return ih.Input
}

InputSingleDigit()
{
    digit := InputSingleKey()
    return IsDigit(digit) ? digit : -1
}

;--------string/array function
TextWidth(str, Typeface := "Courier New", Size := 10)
{
    hDC := DllCall("GetDC","UPtr",0,"UPtr")
    Height := -DllCall("MulDiv","Int",Size,"Int",DllCall("GetDeviceCaps","UPtr",hDC,"Int",90),"Int",72)
    hFont := DllCall("CreateFont","Int",Height,"Int",0,"Int",0,"Int",0,"Int",400,"UInt",False,"UInt",False,"UInt",False,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"Str",Typeface)
    hOriginalFont := DllCall("SelectObject","UPtr",hDC,"UPtr",hFont,"UPtr")
    DllCall("GetTextExtentPoint32","UPtr",hDC,"Str",str,"Int",StrLen(str),"int*", &Extent:=0)
    return Extent
}

RegExFindAll(haystack, needle)
{
    result := []
    pos := 1
    while (pos := RegExMatch(haystack, needle, &match, pos))
    {
        pos += StrLen(match[])
        result.Push(match[])
    }
    return result
}

CountSubStr(haystack, needle)
{
    return RegExFindAll(haystack, needle).Length
}

CountLines(content)
{
    return CountSubStr(content, "`n") + 1
}

GetReverseArray(arr)
{
    rarr := []
    for value in arr
        rarr.InsertAt(1, value)
    return rarr
}

ArrayToString(arr, dilim := " ")
{
    str := ""
    for i, v in arr
        str .= (i > 1 ? dilim : "") . v
    return str
}

GetStrType(s)
{
    s := PunctTrim(s)
    return RegExMatch(s, "^ *[a-zA-Z]* *$") ? 'word' : 'sentence'
}

PunctTrim(word)
{
    return Trim(word, "!`"#$%&'()*+,-./:;<=>?@[\]^_``{|}~ ！？。，‘“’”：；、")
}

GetNameFromCmd(cmd)
{
    path := StrSplit(cmd, ' ')[1]
    name := StrSplit(path, ["\", "/"])[-1]
    return name
}

;-------http & proxy
HttpGet(url, headers := "", proxy := "", timeout := 500)
{
    try
    {
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

HttpPost(url, body, headers := "", proxy := "", timeout := 500)
{
    try
    {
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

GetProxyStatus()
{
    return RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable", 0)
}

GetProxyServer()
{
    default := "localhost:1234"
    return RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer", default)
}

SetProxyStatus(val)
{
    if (GetProxyStatus() != val)
    {
        InfoMsg("Setting Proxy Status to " . val)
        RegWrite(val, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
        RefreshProxy()
    }
}

SetProxyServer(s)
{
    if (GetProxyServer() != s)
    {
        InfoMsg("Setting Proxy Server to " . s)
        RegWrite(s, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer")
        RefreshProxy()
    }
}

RefreshProxy()
{
    DllCall("Wininet\InternetSetOptionW", "int", 0, "int", 37, "int", 0, "int", 0)
    DllCall("Wininet\InternetSetOptionW", "int", 0, "int", 39, "int", 0, "int", 0)
}

ToggleProxy(*)
{
    SetProxyStatus(GetProxyStatus() = 1 ? 0 : 1)
}

ToggleBackground(ItemName)
{
    if (HyperSettings["Background"].Has(ItemName))
    {
        cmd := HyperSettings["Background"][ItemName]
        bg_exe := GetNameFromCmd(cmd)
        pid := ProcessExist(bg_exe)
        if (pid = 0)
        {
            RunBackgroudCommand(cmd)
            InfoMsg(ItemName . " Started")
        }
        else
        {
            ProcessClose(pid)
            InfoMsg(ItemName . " Killed")
        }
    }
    else
        WarningMsg("Backgound task " . ItemName . " not exsit")
}

;----hotkey util
HotKeyCounter(timeout := 500)
{
    static counter := 0
    SetTimer(reset, -timeout)
    counter += 1
    return counter
    reset()
    {
        counter := 0
    }
}

;----hotkey functions
ToggleCapsLock()
{
    SetCapsLockState(GetKeyState("CapsLock", "T") = 1 ? 'AlwaysOff' : 'AlwaysOn')
}

;----window utils
MouseIsOver(WinTitle)
{
    MouseGetPos( , , &Win)
    return WinExist(WinTitle) = Win
}

CheckIfCaretNotDetectable()
{
    NumMonitors := SysGet(80)
    if (NumMonitors < 1)
        NumMonitors := 1
    CaretGetPos(&CaretX)
    if (CaretX != 0)
        return 1
    Loop NumMonitors
    {
        MonitorGet(A_Index, &left)
        if (CaretX = left)
            return 1
    }
    return 0
}

IsWindowFullScreen(winTitle)
{
    winID := WinExist(winTitle)
    if (!winID)
        return false
    style := WinGetStyle(winID)
    WinGetPos(,,&winW,&winH, winID)
    return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

IsDesktop(winTitle)
{
    cls := WinGetClass(winTitle)
    name := WinGetProcessName(winTitle)
    return (cls = "WorkerW" or cls = "Progman") and (name = "Explorer.EXE" or name = "explorer.exe")
}