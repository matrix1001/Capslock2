; Adapter functions — called by keymap strings.
; All delegate to Engine.Instance class methods.

; Window management
Window(name) {
    path := Engine.Instance.config.Get("Switch", name)
    if path = "" {
        Engine.Instance.notify.Warn("Switch entry not found: " . name)
        return
    }
    Engine.Instance.window.ActivateOrLaunch(path)
}

QWindow(idx) {
    result := Engine.Instance.window.QWindowToggle(idx)
    switch result {
        case "not_bound":
            Engine.Instance.notify.Info("QWindow " . idx . ": not bound")
        case "closed":
            Engine.Instance.notify.Info("QWindow " . idx . ": window closed, cleared")
    }
}

QWindowBind(idx) {
    title := Engine.Instance.window.QWindowBind(idx)
    if title != ""
        Engine.Instance.notify.Info("QWindow " . idx . " ← " . title)
    else
        Engine.Instance.notify.Info("QWindow " . idx . ": bind failed")
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
ReloadScript() => Engine.Instance.OnHotReload()
TestPython() {
    code := "
    (
import sys
print(f'Python {sys.version}')
print('Hello from Capslock2!')
    )"
    result := PythonRunner.Run(code)
    Engine.Instance.notify.Info(result != "" ? result : "No output (check Python path)")
}

; Background
ToggleBackground(name) {
    cmd := Engine.Instance.config.Get("Background", name)
    if cmd = "" {
        Engine.Instance.notify.Warn("Background task " . name . " not found")
        return
    }
    status := Helpers.ToggleBackground(name, cmd)
    Engine.Instance.notify.Info(name . " " . status)
    Engine.Instance.tray.UpdateState()
}

