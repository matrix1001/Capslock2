; Adapter functions — called by keymap strings.
; All delegate to Engine.Instance class methods.

; Window management
WindowA(name) {
    path := Engine.Instance.config.Get("Switch", name)
    Engine.Instance.window.ActivateOrLaunch(path)
}

WindowB(name) {
    path := Engine.Instance.config.Get("Switch", name)
    Engine.Instance.window.ActivateOrLaunchLast(path)
}

WindowC(idx) => Engine.Instance.window.QuickToggle(idx)
WindowCClear() {
    Engine.Instance.notify.Info("Press digit 1-5 to clear binding")
    Engine.Instance.input._StopInputHook()
    ih := InputHook("L1")
    ih.KeyOpt("12345", "+N")
    ih.Start()
    ih.Wait()
    digit := ih.Input
    if digit != "" {
        Engine.Instance.window.QuickClear(digit)
        Engine.Instance.notify.Info("QuickWindow " . digit . " cleared")
    }
}
WindowKill() => Engine.Instance.window.KillActive()
WindowToggleOnTop() {
    isTop := Engine.Instance.window.ToggleAlwaysOnTop()
    Engine.Instance.notify.Info(isTop ? "Always on top ON" : "Always on top OFF")
}
SameWindowSwitch() => Engine.Instance.window.SameProcessSwitch()

; Translation
TranslateSelected() => Engine.Instance.translate.TranslateSelected()

; System
ToggleProxy() => Helpers.ToggleProxy()
ToggleSuspend() => Engine.Instance.OnSuspend()
HyperReload() => Engine.Instance.OnHotReload()

; Background
ToggleBackgound(name) {
    cmd := Engine.Instance.config.Get("Background", name)
    if cmd = "" {
        Engine.Instance.notify.Warn("Background task " . name . " not found")
        return
    }
    status := Helpers.ToggleBackground(name, cmd)
    Engine.Instance.notify.Info(name . " " . status)
    Engine.Instance.tray.UpdateState()
}

; Search (placeholder — user provides implementation)
HyperSearch() {
    Engine.Instance.notify.Info("HyperSearch not configured")
}
