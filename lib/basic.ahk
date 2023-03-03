;----func
RunFunc(fn_str, threaded := 0)
{
    match := []
    params := []
    fn := 0
    if (!RegExMatch(Trim(fn_str), "\)$"))
    {
        ; no parameters
        fn := %fn_str%
    }
    else if (RegExMatch(fn_str, "(\w+)\((.*)\)$", &match))
    {
        ; has parameters or just ()
        fn := %match[1]%
        
        if (match.Count > 1)
        {
            params_str := match[2]
            params := StrSplit(params_str, ",", " `"`'") ;trim white space and " and '
        }
    }
    else 
        return
    if (threaded = 0)
        return fn(params*)
    else
        return SetTimer(FnWithParams, -1)

    FnWithParams()
    {
        fn(params*)
    }
}
RunBackgroudCommand(cmd)
{
    shell := ComObject("WScript.Shell")
    exec := shell.Run(cmd, 0)
}

;--------IO function
ListFiles(dir)
{
    lst := []
    Loop Files, dir . "\*",  "F" ; file only, ignore subdir
    {
        path := dir . "\" . A_LoopFileName
        lst.Push(path)
    }
    return lst
}
GetSelectedText()
{
    ClipboardOld := ClipboardAll()
    A_Clipboard := ""
    selText := ""
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
    else
        return ""
}

InputSingleKey() ;read a key from user
{
    ih := InputHook("T3 L1")
    ih.Start()
    ih.Wait()
    return ih.Input

}

InputSingleDigit()
{
    digit := InputSingleKey()
    if (IsDigit(digit))
        return digit
    else
        return -1
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
    while (pos:=RegExMatch(haystack, needle, &match, pos))
    {
        pos := pos + StrLen(match[])
        result.push(match[])
    }
    Return result
}

CountSubStr(haystack, needle)
{
    result := RegExFindAll(haystack, needle)
    return result.Length
}

CountLines(content)
{
    return CountSubStr(content, "`n") + 1
}

GetReverseArray(arr)
{
    rarr := []
    for value in arr
    {
        rarr.insertat(1, value)
    }
    return rarr
}

ArrayToString(arr, dilim := " ")
{
    str := ""
    for index, val in arr
        if (index = 1)
            str := val
        else
            str := str . dilim . val
    return str
}
GetStrType(s)
{
    s := PunctTrim(s)
    if (RegExMatch(s, "^ *[a-zA-Z]* *$"))
        return 'word'
    else
        return 'sentence'
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
HttpGet(url, headers := "", proxy := "", timeout := 500) ;proxy 127.0.0.1:1080
{
    try
    {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, false)
        whr.SetTimeouts(0, timeout, timeout, timeout)
        If proxy
        {
            whr.SetProxy(2,proxy)
        }
        if (headers != "")
        {
            for key, value in headers
            {
                whr.SetRequestHeader(key, value)
            }
        }
        whr.Send()
        ; Using 'true' above and the call below allows the script to remain responsive.
        ; whr.WaitForResponse()
        return whr.ResponseText
    }
    catch Error as err
    {
        ;ErrorMsg(err)
        return ""
        
    }
}
HttpPost(url, body, headers := "", proxy := "", timeout := 500) ;proxy 127.0.0.1:1080
{
    try
    {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", url, false)
        whr.SetTimeouts(0, timeout, timeout, timeout)
        If proxy
        {
            whr.SetProxy(2,proxy)
        }
        if (headers != "")
        {
            for key, value in headers
            {
                whr.SetRequestHeader(key, value)
            }
        }
        whr.Send(body)
        ; Using 'true' above and the call below allows the script to remain responsive.
        ; whr.WaitForResponse()
        return whr.ResponseText
    }
    catch Error as err
    {
        ;ErrorMsg(err)
        return ""
        
    }
}

GetProxyStatus()
{
    status := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable", 0)
    return status   
}
GetProxyServer()
{
    default := "localhost:1234"
    proxy := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyServer", default)
    return proxy
}
SetProxyStatus(val)
{
    cur_status := GetProxyStatus()
    if (cur_status != val)
    {
        InfoMsg("Setting Proxy Status to " . val)
        RegWrite(val, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings", "ProxyEnable")
        RefreshProxy()
    }
}
SetProxyServer(s)
{
    cur_server := GetProxyServer()
    if (cur_server != s)
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
    status := GetProxyStatus()
    new_status := (status = 1) ? 0:1
    SetProxyStatus(new_status)
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
        return
    }
}
;----hotkey functions
ToggleCapsLock()
{
    if (GetKeyState("CapsLock", "T") = 1)
        SetCapsLockState('AlwaysOff')
    else
        SetCapsLockState('AlwaysOn')
}
;----window utils
MouseIsOver(WinTitle) {
    MouseGetPos( , , &Win)
    return WinExist(WinTitle) = Win
}
CheckIfCaretNotDetectable()
{
    ;Grab the number of non-dummy monitors
    NumMonitors := SysGet(80)
    if (NumMonitors < 1)
        NumMonitors := 1
    CaretGetPos(&CaretX)
    if (CaretX != 0)
    {
       return 1
    }
    ;if the X caret position is equal to the leftmost border of the monitor +1, we can't  detect the caret position.
    Loop NumMonitors
    {
        MonitorGet(A_Index, &left)
        if (CaretX = left)
            return 1
    }
    return 0
}
IsWindowFullScreen( winTitle ) 
{
    winID := WinExist( winTitle )

	If ( !winID )
		Return false

	style := WinGetStyle(winID)
	WinGetPos(,,&winW,&winH, winTitle)
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}
IsDesktop( winTitle )
{
    cls := WinGetClass(winTitle)
    name := WinGetProcessName(winTitle)
    return (cls = "WorkerW" or cls = "Progman" ) and (name = "Explorer.EXE" or name = "explorer.exe")
    
}