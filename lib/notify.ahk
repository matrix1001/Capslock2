ErrorMsg(e := "", msg := "")
{
    err_msg := ""
    if (msg != "")
    {
        err_msg .= "Function msg:`n" . msg . "`n`n"
    }
    if (e != "")
    {
        err_msg .= "Exception:`nwhat: " e.what "`nfile: " e.file
            . "`nline: " e.line "`nmessage: " e.message "`nextra: " e.extra
    }
    MsgBox(err_msg, "ERROR", 16)
    ;TrayTip(err_msg, "Capslock2 Error", 0x13)
}


SuccessMsg(msg)
{
    if (HyperSettings["Notify"]["MsgLevel"] <= 1)
    {
        AddNotification(msg, "SUCCESS")
    } 
}
WarningMsg(msg)
{
    if (HyperSettings["Notify"]["MsgLevel"] <= 2)
    {
        AddNotification(msg, "WARNING", 6000)
    } 
}
InfoMsg(msg)
{
    if (HyperSettings["Notify"]["MsgLevel"] <= 1)
    {
        AddNotification(msg, "INFO")
    } 
}
DebugMsg(msg)
{
    if (HyperSettings["Notify"]["MsgLevel"] = 0)
    {
        AddNotification(msg, "DEBUG")
    }
}
AddNotification(msg, title:="", delay:=3000)
{
    if (not A_IsSuspended)
    {
        noti := Map("msg", msg, "title", title, "delay", delay)
        RunTime["Notifications"].insertat(1, noti)
    }
}


WinNotification(message, title, delay:=3000) ;note: accept only two lines for message
{
    static records := []

    ;turn off threads to avoid race condition
    SetTimer(notichecker, 0)
    SetTimer(noticounter, 0)
 
    ;max notification limit
    while (records.Length > HyperSettings["Notify"]["Max"])
    {
        val := records.pop()
        gui := val["gui"]
        gui.Destroy()
    }

    info := WinNotificationInit(message, title)
    info["counter"] := delay

    ;move old notification up
    prev_height := info["height"] 
    for index, val in records
    {
        if (val["counter"] > 0)
        {
            gui := val["gui"]
            y := val["y"] - prev_height
            gui.Show("NoActivate  NA y" . y)
            prev_height += val["height"]
        }
    }

    ;show new notification
    gui := info["gui"]
    hwnd := gui.Hwnd
    Width := info["width"]
    Height := info["height"]
    x := info["x"]
    y := info["y"]
    gui.Show("W" . Width . " H" . Height . " NoActivate Hide x" . x . " y" . y)
    if (HyperSettings["Notify"]["Style"] = "fade")
    {
        WinFade(hwnd, "in", 300)
    }
    else if (HyperSettings["Notify"]["Style"] = "slide")
    {
        WinSlide(hwnd, "in", "r", 300)
    }

    
    records.insertat(1, info)

    SetTimer(notichecker, 250)
    SetTimer(noticounter, 250)
    return


    noticounter()
    {
        for index, val in records
        {
            
            val["counter"] -= 250
            val["counter"] = Max(val["counter"], 0)
            records[index] := val
        }
        return
    }
    notichecker()
    {
        rrecords := GetReverseArray(records)
        for index, val in rrecords
        {
            if (val["counter"] <= 0)
            {

                gui := val["gui"]
                hwnd := gui.Hwnd
                if (HyperSettings["Notify"]["Style"] = "fade")
                {
                    WinFade(hwnd, "out", 200)
                }
                else if (HyperSettings["Notify"]["Style"] = "slide")
                {
                    WinSlide(hwnd, "out", "l", 200)
                }
                else
                {
                    gui.Destroy()
                }
            }
        }
        return
    }

}

WinNotificationInit(message, title, Width:=400) 
{
    _gui := Gui()
    _gui.Opt("+AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound -DPIScale")
    _gui.BackColor := "c808080"
    _gui.MarginX := 0
    _gui.MarginY := 10
    _gui.SetFont("s13 cD0D0D0", "Bold")
    _gui.Add("Progress", "x-1 y-1 w" . (Width+2) . " h31 Background404040 Disabled")
    _gui.Add("Text", "x0 y0 w" . Width . " h30 BackgroundTrans Center 0x200", title)
    _gui.SetFont("s10")
    _gui.Add("Text", "x7 y+10 Center w" . (Width-14), message)

    pos := WinGetPosHide(_gui, Width) 

    Height := pos["height"]
    WinSetRegion("0-0 w" . Width . " h" . Height . " r6-6")
    MonitorGetWorkArea(,,,&right:=0, &bottom:=0)
    x := right-pos["width"]-5
    y := bottom-pos["height"]-5

    return Map("x",x ,"y",y, "width",Width, "height",Height, "gui",_gui)
}

WinSlide(hwnd, method:="in", begin_pos:="b", delay:=500) ;direction: l, r, u, d
{
    ;https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-animatewindow
    ;value := 0x40000+method*0x10000
    if (method = "in")
    {
        value := 0x40000
    }
    else
    {
        value := 0x50000
    }
    if InStr(begin_pos, "t")
    {
        value += 4
    }
    if InStr(begin_pos, "b")
    {
        value += 8
    }
    if InStr(begin_pos, "l")
    {
        value += 1
    }
    if InStr(begin_pos, "r")
    {
        value += 2
    }
    DllCall("AnimateWindow","UInt",hwnd,"Int",delay,"UInt",value)
    Return
}
WinFade(hwnd, method:="out", delay:=1000) 
{
    if (method = "out")
    {
        value := 0x90000
    }
    else
    {
        value := 0xa0000
    }
    DllCall("AnimateWindow","UInt",hwnd,"Int",delay,"UInt",value)
    return
}

WinGetPosHide(gui, W:=0, H:=0)
{
    if (W != 0 and H != 0)
    {
        gui.Show("NoActivate Hide W" . W . " H" . H)
    }
    else if (W != 0)
    {
        gui.Show("NoActivate Hide W" . W)
    }
    else if (H != 0)
    {
        gui.Show("NoActivate Hide H" . H)
    }
        
    WinGetPos(&x, &y, &width, &height)
    result := Map("width",width, "height",height, "x",x, "y",y)
    return result
}
