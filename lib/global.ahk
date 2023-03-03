Hyper := 0, HyperOnly := 0, HyperShort := 0
HyperAlt := 0, HyperWin := 0

HyperSettings := Map()
HyperSettings["Basic"] := Map(
    "Admin",0,
    "DisableOnFullScreen",1,
    "ScriptMonitor",1,
    "SettingMonitor",1,
    "StartUp",1,
    "Python","",
)

HyperSettings["Trans"] := Map(
    "SourceLanguage","auto",
    "TargetLanguage","zh",
    "GoogleProxy","force",
)

HyperSettings["Notify"] := Map(
    "Enable",1,
    "Max",5,
    "MsgLevel",1,
    "Style","slide",
)

HyperSettings["Keymap"] := Map(
    "1","WindowC(1)",
    "2","WindowC(2)",
    "3","WindowC(3)",
    "4","WindowC(4)",
    "5","WindowC(5)",
    "minus","WindowCClear",
    
    "g","WindowKill",
    
    "i","Send({Home})",
    "o","Send({End})",
    "h","Send({Left})",
    "j","Send({Down})",
    "k","Send({Up})",
    "l","Send({Right})",

    "left","Send(#^{Left})",
    "right","Send(#^{Right})",

    "s","HyperSearch",
    "space","WindowToggleOnTop",
    "t","TranslateSelected",
    "tab","SameWindowSwitch",

    "u","Send({PgUp})",
    "p","Send({PgDn})",

    "c","Send(^{Insert})",
    "v","Send(+{Insert})",

    "up","Send({Volume_Up})",
    "down","Send({Volume_Down})",
    "wheelup","Send({Volume_Up})",
    "wheeldown","Send({Volume_Down})",

    "alt_r","HyperReload",
    "alt_p","ToggleProxy",
    "alt_o","ToggleBackgound(MyHTTPServer)",

    "w","WindowA(NotePad)",
)

HyperSettings["Background"] := Map(
    "MyHTTPServer","/path/to/http_server.exe -p 1080",
)

HyperSettings["Switch"] := Map(
    "NotePad","notepad.exe",
)


ScriptDir := ["lib", "script"]

RunTime := Map()
RunTime["Hyper"] := 0
RunTIme["HyperOnly"] := 0
RunTIme["HyperShort"] := 0
RunTIme["HyperAlt"] := 0
RunTIme["HyperWin"] := 0
RunTime["Notifications"] := Array()
RunTime["SettingChange"] := 0
RunTime["ScriptChange"] := 0
RunTime["StartTime"] := A_MM . "/" . A_DD . " " . A_Hour . ":" . A_Min
RunTime["Suspend"] := 0

SafeSetRuntimeValue(key, val)
{
    Critical "On"
    RunTime[key] := val
    Critical "Off"
}
SafeSetRuntimeValues(key_arr, val_arr)
{
    Critical "On"
    for index, key in key_arr
        RunTime[key] := val_arr[index]
    Critical "Off"
}