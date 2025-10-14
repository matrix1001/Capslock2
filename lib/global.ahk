HyperSettings := Map()
HyperSettings["Basic"] := Map(
    "Admin",0,
    "DisableOnFullScreen",1,
    "ScriptMonitor",1,
    "SettingMonitor",1,
    "StartUp",1,
    "Python",""
)

HyperSettings["Trans"] := Map(
    "SourceLanguage","auto",
    "TargetLanguage","zh",
    "GoogleProxy","force"
)

HyperSettings["Notify"] := Map(
    "Enable",1,
    "Max",5,
    "MsgLevel",1,
    "Style","slide"
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

    "w","WindowA(NotePad)"
)

HyperSettings["Background"] := Map(
    "MyHTTPServer","/path/to/http_server.exe -p 1080"
)

HyperSettings["Switch"] := Map(
    "NotePad","notepad.exe"
)

ScriptDir := ["lib", "script"]

; 运行时变量
RunTime := Map(
    "Hyper", 0,
    "HyperOnly", 0,
    "HyperShort", 0,
    "HyperAlt", 0,
    "HyperWin", 0,
    "Notifications", Array(),
    "SettingChange", 0,
    "ScriptChange", 0,
    "StartTime", A_MM . "/" . A_DD . " " . A_Hour . ":" . A_Min,
    "Suspend", 0
)

; 安全设置运行时单个值
SafeSetRuntimeValue(key, val)
{
    Critical "On"
    RunTime[key] := val
    Critical "Off"
}
; 安全设置运行时多个值
SafeSetRuntimeValues(key_arr, val_arr)
{
    Critical "On"
    for index, key in key_arr
        RunTime[key] := val_arr[index]
    Critical "Off"
}