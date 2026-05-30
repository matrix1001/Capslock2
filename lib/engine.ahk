class Engine {
    static Instance := ""

    config := ""
    notify := ""
    window := ""
    translate := ""
    input := ""
    tray := ""

    Init() {
        Engine.Instance := this
        this.config := Config()
        this.config.Init()
        this.notify := Notify()
        this.notify.Init(this.config)
        this.window := WindowMgr()
        this.translate := TranslateSvc(this.config)
        this.input := InputMgr()
        this.input.Init(this.config)
        this.tray := TrayMgr()
        this.tray.Init(this)
        this.notify.Info("Capslock2 started")
    }

    OnHotReload() {
        if this.config.IsScriptChanged() {
            Reload
            return
        }
        this.config.Reload()
        this.input.ReloadKeymap()
        this.tray.RebuildMenu()
        this.config.ClearChangeFlags()
        this.notify.Info("Config reloaded")
    }

    OnSuspend() {
        if this.input.IsSuspended() {
            this.input.Resume()
            this.notify.Info("Capslock2 resumed")
        } else {
            this.input.Suspend()
            this.notify.Info("Capslock2 suspended")
        }
        this.tray.UpdateState()
    }
}
