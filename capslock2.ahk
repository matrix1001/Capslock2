#Include lib\global.ahk
#Include lib\basic.ahk
#Include lib\notify.ahk
#Include lib\switch.ahk
#Include lib\settings.ahk
#Include lib\json.ahk
#Include lib\trans.ahk
#Include lib\tips.ahk
#Include lib\python.ahk
#Include lib\traymenu.ahk
;Put your own script here
;#Include script\myscrip.ahk

SetCapsLockState("AlwaysOff")
ProcessSetPriority("High")

InitSettings()
InitTrayMenu()
SuccessMsg("Start Capslock2")


CapsLock::
{
    if (HyperSettings["Basic"]["DisableOnFullScreen"] = 1 and IsWindowFullScreen("A") and not IsDesktop("A"))
    {
        return
    }
        
    SetTimer(CapsLockChecker, -250)

    SafeSetRuntimeValues(["Hyper", "HyperOnly", "HyperShort", "HyperAlt", "HyperWin"], [1, 1, 1, 0, 0])

    KeyWait("CapsLock")
    if (RunTime["HyperOnly"] = 1 and RunTime["HyperShort"] = 1)
    {
        ToggleCapsLock()
    }

    SafeSetRuntimeValues(["Hyper", "HyperOnly", "HyperShort"], [0, 0, 0])

    CapsLockChecker()
    {
        ;set HyperShort to 0 to indicate user hesitated
        SafeSetRuntimeValue("HyperShort", 0)
    }
}


#HotIf RunTime["Hyper"] = 1
Esc::
{
    if (RunTime["Suspend"] = 1)
    {
        InfoMsg("Enable the script")
        TraySetIcon("icon/hyper.ico",,1)
        RunTime["Suspend"] := 0
    }
    else
    {
        InfoMsg("Suspend the script")
        TraySetIcon("icon/hyper-suspend.ico",,1)
        RunTime["Suspend"] := 1
    }
}
lalt::
{
    SafeSetRuntimeValue("HyperAlt", 1)
}
lwin::
{
    SafeSetRuntimeValue("HyperWin", 1)
}
a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
n::
m::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::
1::
2::
3::
4::
5::
6::
7::
8::
9::
0::

f1::
f2::
f3::
f4::
f5::
f6::
f7::
f8::
f9::
f10::
f11::
f12::
backspace::


space::
tab::
enter::

`::
-::
=::
[::
]::
\::
`;::
'::
,::
.::
/::


rwin::
lshift::
rshift::
lctrl::
rctrl::
ralt::

left::
right::
up::
down::

wheelup::
wheeldown::
{
    if RunTime["Suspend"]
        return
    key := A_ThisHotkey

    KeyMap := Map("``", "backquote", "-", "minus","=", "equal", "[", "lbracket", "]", "rbracket"
    , "\", "backslash", ";", "semicolon", "'", "quote", ",", "comma", ".", "dot", "/", "slash")

    if (KeyMap.Has(key))
        keyname := KeyMap[key]
    else
        keyname := key

    if (RunTime["HyperAlt"] = 1 or GetKeyState("LAlt", "P"))
        keyname := 'alt_' . keyname
    if (RunTime["HyperWin"] = 1 or GetKeyState("LWin", "P"))
        keyname := 'win_' . keyname

    SafeSetRuntimeValue("HyperOnly", 0)
    if (not HyperSettings["Keymap"].Has(keyname))
    {
        WarningMsg("No function assigned to Key: " . keyname)
        return
    }
    fn_name := HyperSettings["Keymap"][keyname]
    try
    {
        RunFunc(fn_name, 1)
        DebugMsg(Format("Key:{}`nFunc:{}", keyname, fn_name))
    }
    catch Error as e
        ErrorMsg(e, Format("Key:{}`nFunc:{}", keyname, fn_name))
}

#HotIf

!x::
{
    WinShow('ahk_exe notepad.exe')
    
}

!z::
{
    WinActivate('ahk_exe notepad.exe')
}

!c::
{
    WinHide('ahk_exe notepad.exe')
}

!v::
{
    MsgBox(WinExist('ahk_exe notepad.exe'))
}