#Requires AutoHotkey v2.0+
#SingleInstance Force
SendMode("Input")
A_MenuMaskKey := "vkE8"
DetectHiddenWindows(true)
InstallKeybdHook
InstallMouseHook
A_MaxHotkeysPerInterval := 200
SetWorkingDir(A_InitialWorkingDir)

#Include lib\json.ahk
#Include lib\config.ahk
#Include lib\window.ahk
#Include lib\helpers.ahk
#Include lib\notify.ahk
#Include lib\translate.ahk
#Include lib\input.ahk
#Include lib\tray.ahk
#Include lib\engine.ahk
#Include lib\settings_gui.ahk
#Include lib\python.ahk
#Include lib\functions.ahk

SetCapsLockState("AlwaysOff")
ProcessSetPriority("High")

app := Engine()
app.Init()

; CapsLock hotkeys
*CapsLock::Engine.Instance.input.OnCapsDown()
*CapsLock Up::Engine.Instance.input.OnCapsUp()

; Mouse wheel — InputHook cannot capture mouse events, must be static #HotIf hotkeys
#HotIf Engine.Instance.input.IsCapturing
WheelUp::Engine.Instance.input.OnWheel("wheelup")
WheelDown::Engine.Instance.input.OnWheel("wheeldown")
#HotIf
