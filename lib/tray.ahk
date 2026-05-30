class TrayMgr {
    _engine := ""
    _msgLevelMenu := ""
    _utilsMenu := ""

    Init(engine) {
        this._engine := engine
        TraySetIcon("icon/capslock2.ico")
        this._BuildMenu()
        this.UpdateState()
    }

    RebuildMenu() {
        this._BuildMenu()
        this.UpdateState()
    }

    UpdateState() {
        this._UpdateToolTip()
        this._SyncMenuState()
    }

    _OnMenuEvent(ItemName, ItemPos, ThisMenu) {
        switch ItemName {
            case "Github: Capslock2":
                Run("https://github.com/matrix1001/capslock2")
            case "Open Directory":
                Run(A_ScriptDir)
            case "Edit Settings":
                SettingsGui().Show(this._engine.config)
            case "Disable On Full Screen":
                current := this._engine.config.Get("Basic", "DisableOnFullScreen", 1)
                this._engine.config.Set("Basic", "DisableOnFullScreen", current = 0 ? 1 : 0)
                this._engine.config.Save()
                this.UpdateState()
            case "Reload":
                this._engine.OnHotReload()
            case "Run as Admin":
                if not A_IsAdmin {
                    Run("*RunAs " . A_ScriptFullPath)
                    ExitApp()
                }
        }
    }

    _OnUtilsEvent(ItemName, ItemPos, ThisMenu) {
        cmd := this._engine.config.Get("Background", ItemName, "")
        if cmd != "" {
            status := Helpers.ToggleBackground(ItemName, cmd)
            this._engine.notify.Info(ItemName . " " . status)
            this.UpdateState()
        }
    }

    _OnProxyEvent(*) {
        this._ShowProxyGui()
    }

    _OnMsgLevelEvent(ItemName, ItemPos, MyMenu) {
        levelMap := Map("Debug", 0, "Normal", 1, "WarnOnly", 2, "Disable", 3)
        this._engine.notify.SetLevel(levelMap[ItemName])
        this._engine.config.Set("Notify", "MsgLevel", levelMap[ItemName])
        this._engine.config.Save()
        this.UpdateState()
    }

    _BuildMenu() {
        A_TrayMenu.Delete()
        A_TrayMenu.Add("Github: Capslock2", this._OnMenuEvent.Bind(this))
        A_TrayMenu.Add()
        A_TrayMenu.Add("Open Directory", this._OnMenuEvent.Bind(this))
        A_TrayMenu.Default := "Open Directory"
        A_TrayMenu.Add("Edit Settings", this._OnMenuEvent.Bind(this))
        A_TrayMenu.Add()

        this._msgLevelMenu := Menu()
        this._msgLevelMenu.Add("Debug", this._OnMsgLevelEvent.Bind(this))
        this._msgLevelMenu.Add("Normal", this._OnMsgLevelEvent.Bind(this))
        this._msgLevelMenu.Add("WarnOnly", this._OnMsgLevelEvent.Bind(this))
        this._msgLevelMenu.Add("Disable", this._OnMsgLevelEvent.Bind(this))
        A_TrayMenu.Add("Message Level", this._msgLevelMenu)

        A_TrayMenu.Add("Disable On Full Screen", this._OnMenuEvent.Bind(this))
        A_TrayMenu.Add()
        A_TrayMenu.Add("Run as Admin", this._OnMenuEvent.Bind(this))
        A_TrayMenu.Add("Reload", this._OnMenuEvent.Bind(this))

        defaultMenu := Menu()
        defaultMenu.AddStandard()
        A_TrayMenu.Add()

        this._utilsMenu := Menu()
        this._utilsMenu.Add("Proxy: " . Helpers.GetProxyServer(), this._OnProxyEvent.Bind(this))
        this._utilsMenu.Add()
        for bgName, _ in this._engine.config.GetSection("Background")
            this._utilsMenu.Add(bgName, this._OnUtilsEvent.Bind(this))

        A_TrayMenu.Add("Utils", this._utilsMenu)
        A_TrayMenu.Add()
        A_TrayMenu.Add("AutoHotkey", defaultMenu)
    }

    _GetBackgroundStates() {
        states := Map()
        for bgName, bgCmd in this._engine.config.GetSection("Background")
            states[bgName] := ProcessExist(Helpers.GetNameFromCmd(bgCmd))
        return states
    }

    _UpdateToolTip() {
        content := "Capslock2`n"
        if A_IsSuspended
            content .= "Suspended`n"
        else if this._engine.config.IsSettingChanged() or this._engine.config.IsScriptChanged()
            content .= "Running (Reload needed)`n"
        else
            content .= "Running`n"

        content .= "StartTime: " . A_MM . "/" . A_DD . " " . A_Hour . ":" . A_Min . "`n"
        content .= "MessageLevel: " . this._engine.config.Get("Notify", "MsgLevel", 1) . "`n"
        content .= "Proxy: " . Helpers.GetProxyServer()
        if Helpers.GetProxyStatus() = 1
            content .= " (enable)"
        content .= "`n"

        for bgName, pid in this._GetBackgroundStates()
            if pid
                content .= "Background: " . bgName . "`n"

        A_IconTip := content
    }

    _SyncMenuState() {
        levelNames := Map(0, "Debug", 1, "Normal", 2, "WarnOnly", 3, "Disable")
        for _, item in ["Debug", "Normal", "WarnOnly", "Disable"]
            this._msgLevelMenu.Uncheck(item)
        level := this._engine.config.Get("Notify", "MsgLevel", 1)
        this._msgLevelMenu.Check(levelNames[Integer(level)])

        A_TrayMenu.UnCheck("Disable On Full Screen")
        if this._engine.config.Get("Basic", "DisableOnFullScreen", 1) = 1
            A_TrayMenu.Check("Disable On Full Screen")

        A_TrayMenu.UnCheck("Run As Admin")
        if A_IsAdmin
            A_TrayMenu.Check("Run As Admin")

        proxyItem := "Proxy: " . Helpers.GetProxyServer()
        this._utilsMenu.Uncheck(proxyItem)
        if Helpers.GetProxyStatus()
            this._utilsMenu.Check(proxyItem)

        for bgName, pid in this._GetBackgroundStates() {
            if pid
                this._utilsMenu.Check(bgName)
            else
                this._utilsMenu.Uncheck(bgName)
        }
    }

    _ShowProxyGui() {
        MyGui := Gui(, "Edit System Proxy")
        MyGui.Add("Text", "x10 w50", "ip:port")
        MyGui.Add("Edit", "vServer ym W200", Helpers.GetProxyServer())
        if Helpers.GetProxyStatus() = 1
            MyGui.Add("Checkbox", "vEnable x10 Checked3", "Enable System Proxy")
        else
            MyGui.Add("Checkbox", "vEnable x10", "Enable System Proxy")
        MyGui.Add("Button", "default W100 x40", "OK").OnEvent("Click", _ProcessInput)
        MyGui.Add("Button", "default W100 yp", "Cancel").OnEvent("Click", _CloseGui)
        MyGui.Show()

        _ProcessInput(*) {
            Saved := MyGui.Submit()
            Helpers.SetProxy(Saved.Enable, Saved.Server)
            MyGui.Destroy()
            Engine.Instance.tray.UpdateState()
        }
        _CloseGui(*) {
            MyGui.Destroy()
        }
    }
}
