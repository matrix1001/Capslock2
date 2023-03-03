TrayMenuMonitor()
{
    ; tray tip
    GetStatus()
    {
        stat := Map("StartTime",RunTime["StartTime"])
        stat["MessageLevel"] := HyperSettings["Notify"]["MsgLevel"]
        stat["Proxy"] := GetProxyServer() . " " . ((GetProxyStatus() = 1) ? "(enable)": "" )
        stat["Background"] := ""
        for bg_name, bg_cmd in HyperSettings["Background"]
            if ProcessExist(GetNameFromCmd(bg_cmd))
                stat["Background"] := stat["Background"] . " " . bg_name
        return stat
    }
    stat := GetStatus()
    if (A_IsSuspended = 1)
        content := "Capslock2`nSuspended`n"
    else if (RunTime["ScriptChange"] = 0 and RunTime["SettingChange"] = 0)
        content := "Capslock2`nRunning`n"
    else
        content := "Capsloc2`nRunning  (Reload needed)`n"
        
 
    for key, val in stat
    {
        content .= Format("{}: {}`n", key, val)
    }
    A_IconTip := content

    ; message
    msglevel_menu := RunTime["MsgMenu"]
    msglevel_menu.Uncheck("Disable")
    msglevel_menu.Uncheck("WarnOnly")
    msglevel_menu.Uncheck("Normal")
    msglevel_menu.Uncheck("Debug")
    level_to_name := Map(
        0,"Debug",
        1,"Normal",
        2,"WarnOnly",
        3,"Disable"
    )
    msglevel := HyperSettings["Notify"]["MsgLevel"]
    msglevel_menu.Check(level_to_name[Integer(msglevel)])

    ; normal
    A_TrayMenu.UnCheck("Disable On Full Screen")
    A_TrayMenu.UnCheck("Run As Admin")

    if (HyperSettings["Basic"]["DisableOnFullScreen"] = 1)
        A_TrayMenu.Check("Disable On Full Screen")

    ; utils
    ;; proxy
    utils_menu := RunTime["UtilsMenu"]
    status := GetProxyStatus()
    if (status)
    {
        utils_menu.Check("3&")
    }
        
    else
    {
        utils_menu.Uncheck("3&")
    }
    server := GetProxyServer()
    utils_menu.Rename("3&", server)
        
    ; background cmds
    for bg_name, bg_cmd in HyperSettings["Background"]
    {
        bg_exe := GetNameFromCmd(bg_cmd)
        bg_status := ProcessExist(bg_exe)
        if (bg_status)
            utils_menu.Check(bg_name)
        else
            utils_menu.Uncheck(bg_name)

    }

    

    if (A_IsAdmin = 1)
        A_TrayMenu.Check("Run As Admin")
}

InitTrayMenu()
{
    TraySetIcon("icon/hyper.ico")
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Github: Capslock2", TrayMenuHandler)

    A_TrayMenu.Add()
    A_TrayMenu.Add("Open Directory", TrayMenuHandler)
    A_TrayMenu.Default := "Open Directory"
    A_TrayMenu.Add("Edit Settings", TrayMenuHandler)

    A_TrayMenu.Add()
    msglevel_menu := Menu()
    msglevel_menu.Add("Debug", MsgLevelHandler)
    msglevel_menu.Add("Normal", MsgLevelHandler)
    msglevel_menu.Add("WarnOnly", MsgLevelHandler)
    msglevel_menu.Add("Disable", MsgLevelHandler)

    RunTime["MsgMenu"] := msglevel_menu



    A_TrayMenu.Add("Message Level", msglevel_menu)

    A_TrayMenu.Add("Disable On Full Screen", TrayMenuHandler)


    A_TrayMenu.Add()
    A_TrayMenu.Add("Run as Admin", TrayMenuHandler)

    A_TrayMenu.Add("Reload", TrayMenuHandler)


    default_menu := Menu()
    default_menu.AddStandard()
    A_TrayMenu.Add()

    utils_menu := Menu()
    utils_menu.Add("System Proxy", UtilsHandler)
    utils_menu.Disable("System Proxy")
    utils_menu.Add()
    utils_menu.Add(GetProxyServer(), UtilsHandler)
    utils_menu.Add()
    utils_menu.Add("Background", UtilsHandler)
    utils_menu.Add()
    utils_menu.Disable("Background")
    for bg_name in HyperSettings["Background"]
        utils_menu.Add(bg_name, UtilsHandler)

    

    RunTime["UtilsMenu"] := utils_menu

    A_TrayMenu.Add("Utils", utils_menu)
    A_TrayMenu.Add()
    A_TrayMenu.Add("AutoHotkey", default_menu)

    SetTimer(TrayMenuMonitor, 250)
}

TrayMenuHandler(ItemName, ItemPos, ThisMenu)
{
    switch ItemName
    {
        case "Github: Capslock2":
        {
            Run("https://github.com/matrix1001/capslock2")
        }
        case "Open Directory":
        {
            Run(A_ScriptDir)
        }
        case "Edit Settings":
        {
            Run("Settings.ini")
        }
        case "Disable On Full Screen":
        {
            HyperSettings["Basic"]["DisableOnFullScreen"] := (HyperSettings["Basic"]["DisableOnFullScreen"] = 0) ? 1:0
        }
        case "Reload":
        {
            HyperReload()
        }
        case "Run as Admin":
        {
            if not A_IsAdmin ;running by administrator
            {
                Run ("*RunAs " . A_ScriptFullPath)
                ExitApp()
            } 
        }
    }
}

UtilsHandler(ItemName, ItemPos, ThisMenu)
{
    if (HyperSettings["Background"].Has(ItemName))
    {
        ToggleBackground(ItemName)
    }
    else if (ItemPos = 3)
    {
        proxy := GetProxyServer()
        MyGui := Gui(, "Edit System Proxy")
        MyGui.Add("Text", "x10 w50", "ip:port")
        MyGui.Add("Edit", "vServer ym W200", GetProxyServer())
        if (GetProxyStatus() = 1)
            MyGui.Add("Checkbox", "vEnable x10 Checked3", "Enable System Proxy")
        else
            MyGui.Add("Checkbox", "vEnable x10", "Enable System Proxy")
        MyGui.Add("Button", "default W100 x40", "OK").OnEvent("Click", ProcessUserInput)
        MyGui.Add("Button", "default W100 yp", "Cancel").OnEvent("Click", CloseGui)
        MyGui.Show()
    
        ProcessUserInput(*)
        {
            Saved := MyGui.Submit()
            SetProxyServer(Saved.Server)
            SetProxyStatus(Saved.Enable)
        }
        CloseGui(*)
        {
            MyGui.Submit()
        }
    }
}

MsgLevelHandler(ItemName, ItemPos, MyMenu)
{
    name_to_level := Map(
        "Debug",0,
        "Normal",1,
        "WarnOnly",2,
        "Disable",3
    )
    HyperSettings["Notify"]["MsgLevel"] := name_to_level[ItemName]
}

