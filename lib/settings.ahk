;functions for load/save settings
InitSettings()
{
    static loaded := 0
    ; main settings
    if FileExist("Settings.ini")
    {
        LoadSetting(HyperSettings, "Settings.ini", loaded)
    }
    else
    {
        InfoMsg("Settings.ini not found, using default")
        SaveSetting(HyperSettings, "Settings.ini")
    }
    ;; handling startup
    if (HyperSettings["Basic"]["StartUp"] = 1)
    {
        autostartLnk := A_Startup . "\CapsLock2.lnk"
        if FileExist(autostartLnk)
        {
            FileGetShortcut(autostartLnk, &lnkTarget)
            if(lnkTarget != A_ScriptFullPath)
            {
                InfoMsg("Create autostartLnk")
                FileCreateShortcut(A_ScriptFullPath, autostartLnk, A_ScriptDir)
            }
                
        }
        else
        {
            InfoMsg("Create autostartLnk")
            FileCreateShortcut(A_ScriptFullPath, autostartLnk, A_ScriptDir)
        }
    }
    else
    {
        autostartLnk:=A_Startup . "\CapsLock2.lnk"
        if FileExist(autostartLnk)
        {
            InfoMsg("Delete autostartLnk")
            FileDelete(autostartLnk)
        }
    }
    ;; handling admin
    if (HyperSettings["Basic"]["Admin"] = 1)
    {
        if not A_IsAdmin ;running by administrator
        {
            Run("*RunAs " . A_ScriptFullPath)
            ExitApp()
        }   
    }
    ;; set monitors
    SetTimer(CapsLockFailMonitor, 250)
    if (HyperSettings["Notify"]["Enable"] = 1)
        SetTimer(NotificationMonitor, 250)
    else 
        SetTimer(NotificationMonitor, 0)
    if (HyperSettings["Basic"]["ScriptMonitor"] = 1)
        SetTimer(ScriptMonitor, 1000)
    else
        SetTimer(ScriptMonitor, 0)
    if (HyperSettings["Basic"]["SettingMonitor"] = 1)
        SetTimer(SettingMonitor, 1000)
    else
        SetTimer(SettingMonitor, 0)
    loaded := 1
}

LoadSetting(_Map, path, warn := 1)
{
    SecNames := IniRead(path)
    for sec in StrSplit(SecNames, "`n")
    {
        lines := StrSplit(IniRead(path, sec), "`n")
        for line in lines
        {
            line := Trim(line, "`a`t ")
            pair := StrSplit(line, "=")
            key := pair[1]
            val := pair[2]
            SafeAssign(_Map, sec, key, val, warn)
        }
    }
}

SafeAssign(_Map, sec, key, val, warn)
{
    if (not _Map.Has(sec))
    {
        _Map[sec] := Map()
        if warn
            MsgBox(Format("Create new section {} in {}", sec, _Map.Name))
    }
        
    if (_Map[sec].Has(key))
    {
        old_val := _Map[sec][key]
        if (old_val != val and warn)
        {
            MsgBox(Format("Duplicate {}: {}`nold value: {}`nnew value: {}",
                sec, key, old_val, val))
        }
    }
    else if warn
    {
        MsgBox(Format("New {}: {}`nnew value: {}",
            sec, key, val))
    }
    
    _Map[sec][key] := val
}

SaveSetting(_Map, path)
{
    for sec in _Map
    {
        for key in _Map[sec]
            IniWrite(_Map[sec][key], path, sec, key)
    }
}
; special load/reload function
HyperReload()
{
    if (RunTime["SettingChange"] = 1 and RunTime["ScriptChange"] = 0)
    {
        InfoMsg("Reload Settings")
        InitSettings()
        RunTime["SettingChange"] := 0
    }
    else
    {
        Reload
    }
}
;----Monitors
CapsLockFailMonitor()
{
    ;fix when caplock sometimes released but KeyWait stuck
    if (GetKeyState("CapsLock", "P") = 0 and RunTime["Hyper"] = 1)
    {
        SafeSetRuntimeValue("Hyper", 0)
    }
}
NotificationMonitor()
{
    if (HyperSettings["Basic"]["DisableOnFullScreen"] = 1)
    {
        if IsWindowFullScreen("A")
            return
    }
    if (RunTime["Notifications"].Length > 0)
    {
        noti := RunTime["Notifications"].pop()
        WinNotification(noti["msg"], noti["title"], noti["delay"])
    }
}
ScriptMonitor()
{
    static timestamps := Map()
    static firsttime := 1

    lst := []
    for index, dir in ScriptDir
    {
        lst.Push(ListFiles(dir)*)
    }
    lst.Push(A_ScriptName)
    
    ; at first put all filename into timestamps
    if firsttime
    {
        for index, filename in lst
        {
            ;Msgbox %filename% record timestamp %temp%
            temp := FileGetTime(filename)
            timestamps[filename] := temp
        }
        firsttime := 0
        return
    }

    ; first check if missing some file
    old_num := timestamps.Count
    new_num := lst.Length
    ; check if deleted
    for filename, value in timestamps
    {
        if (lst.Has(filename))
        {
            InfoMsg(filename . " has been deleted`nPress Capslock + Alt + r to reload")
            Runtime["ScriptChange"] := 1
            timestamps.Delete(filename)
        }
    }

    ; timestamp and new file check
    for index, filename in lst
    {
        temp := FileGetTime(filename)
        if not timestamps.Has(filename)
        {
            InfoMsg("New file " . filename . " detected`n Press Capslock + Alt + r to reload")
            Runtime["ScriptChange"] := 1
            timestamps[filename] := temp
        }
        else if timestamps[filename] != temp
        {
            InfoMsg(filename . " changed`n Press Capslock + Alt + r to reload")
            Runtime["ScriptChange"] := 1
            timestamps[filename] := temp
        }
    }
}
SettingMonitor()
{
    filename := "Settings.ini"
    static timestamps := FileGetTime(filename)
    temp := FileGetTime(filename)
    if (temp != timestamps)
    {
        InfoMsg(filename . " changed`nPress Capslock + Alt + r to read settings")
        Runtime["SettingChange"] := 1
        timestamps := temp
    }
    
}