class SettingsGui {
    _config := ""
    _gui := ""
    _tab := ""
    _listViews := Map()
    _basicControls := ""

    Show(cfg) {
        this._config := cfg
        this._gui := Gui(, "Capslock2 Settings")
        this._gui.SetFont("s10", "Segoe UI")

        this._tab := this._gui.Add("Tab3", "x10 y10 w580 h400", [
            "Basic", "Keymap", "Switch", "Background", "Trans"
        ])
        this._BuildBasicTab()
        this._BuildKeymapTab()
        this._BuildSwitchTab()
        this._BuildBackgroundTab()
        this._BuildTransTab()
        this._tab.UseTab()

        this._gui.Add("Button", "x10 y420 w80", "Save").OnEvent("Click", this._OnSave.Bind(this))
        this._gui.Add("Button", "x100 y420 w80", "Cancel").OnEvent("Click", (*) => this._gui.Destroy())
        this._gui.Add("Button", "x190 y420 w100", "Reload Script").OnEvent("Click", this._OnReload.Bind(this))

        this._gui.Show("w600 h460")
    }

    ; ========== KEYMAP TAB ==========
    _BuildKeymapTab() {
        this._tab.UseTab(2)
        lv := this._gui.Add("ListView", "x20 y40 w560 h320 -Multi Grid", ["Key", "Function"])
        this._listViews["Keymap"] := lv
        for k, v in this._config.GetKeymap()
            lv.Add(, k, v)
        lv.ModifyCol(1, 120)
        lv.ModifyCol(2, 420)

        this._gui.Add("Button", "x20 y370 w70", "Edit").OnEvent("Click", (*) => this._EditKeymapItem(lv))
        this._gui.Add("Button", "x100 y370 w70", "Delete").OnEvent("Click", (*) => this._DeleteKeymapItem(lv))
        this._gui.Add("Button", "x180 y370 w70", "Add").OnEvent("Click", (*) => this._AddKeymapItem(lv))
    }

    _EditKeymapItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        key := lv.GetText(row, 1)
        val := lv.GetText(row, 2)
        this._KeymapEditDialog(key, val, (newKey, newVal) => (
            lv.Modify(row, , newKey, newVal)
        ))
    }

    _DeleteKeymapItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        lv.Delete(row)
    }

    _AddKeymapItem(lv) {
        this._KeymapEditDialog("", "", (newKey, newVal) => (
            lv.Add(, newKey, newVal)
        ))
    }

    _KeymapEditDialog(key, val, onSave) {
        dlg := Gui(, "Edit Keymap Entry")
        dlg.SetFont("s10", "Segoe UI")
        dlg.Add("Text", "x10 y12 w60", "Key:")
        dlg.Add("Text", "x10 y42 w60", "Function:")
        keyEdit := dlg.Add("Edit", "x70 y10 w300", key)
        valEdit := dlg.Add("Edit", "x70 y40 w300", val)
        dlg.Add("Button", "x120 y75 w70", "OK").OnEvent("Click", (*) => (
            onSave(keyEdit.Value, valEdit.Value), dlg.Destroy()
        ))
        dlg.Add("Button", "x200 y75 w70", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
        dlg.Show("w390 h110")
    }

    ; ========== SWITCH TAB ==========
    _BuildSwitchTab() {
        this._tab.UseTab(3)
        lv := this._gui.Add("ListView", "x20 y40 w560 h280 -Multi Grid", ["Name", "Path / Match"])
        this._listViews["Switch"] := lv
        for k, v in this._config.GetSection("Switch")
            lv.Add(, k, v)
        lv.ModifyCol(1, 120)
        lv.ModifyCol(2, 420)

        this._gui.Add("Button", "x20 y330 w80", "Pick Window").OnEvent("Click", (*) => this._PickWindow(lv))
        this._gui.Add("Button", "x110 y330 w70", "Edit").OnEvent("Click", (*) => this._EditSwitchItem(lv))
        this._gui.Add("Button", "x190 y330 w70", "Delete").OnEvent("Click", (*) => this._DeleteSwitchItem(lv))
        this._gui.Add("Button", "x270 y330 w70", "Test").OnEvent("Click", (*) => this._TestSwitchItem(lv))
    }

    _PickWindow(lv) {
        this._gui.Hide()
        Sleep(100)
        KeyWait("LButton", "D")
        MouseGetPos(, , &hwnd)
        this._gui.Show()

        if not hwnd
            return
        exe := WinGetProcessName(hwnd)
        path := WinGetProcessPath(hwnd)
        cls := WinGetClass(hwnd)
        title := WinGetTitle(hwnd)

        match := path . " ahk_exe " . exe . " ahk_class " . cls
        name := Format("{:T}", StrReplace(StrLower(exe), ".exe", ""))

        this._SwitchEditDialog(name, match, title, (newName, newVal) => (
            lv.Add(, newName, newVal)
        ))
    }

    _EditSwitchItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        name := lv.GetText(row, 1)
        val := lv.GetText(row, 2)
        this._SwitchEditDialog(name, val, "", (newName, newVal) => (
            lv.Modify(row, , newName, newVal)
        ))
    }

    _DeleteSwitchItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        lv.Delete(row)
    }

    _TestSwitchItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        val := lv.GetText(row, 2)
        Engine.Instance.window.ActivateOrLaunch(val)
    }

    _SwitchEditDialog(name, match, title, onSave) {
        dlg := Gui(, "Edit Switch Entry")
        dlg.SetFont("s9", "Segoe UI")
        y := 10
        if title != "" {
            dlg.Add("Text", "x10 y" . y . " w610", "Window: " . title)
            y += 22
        }
        dlg.Add("Text", "x10 y" . y . " w60", "Name:")
        nameEdit := dlg.Add("Edit", "x70 y" . (y-2) . " w560", name)
        y += 28
        dlg.Add("Text", "x10 y" . y . " w60", "Match:")
        matchEdit := dlg.Add("Edit", "x70 y" . (y-2) . " w560 h48 Multi")
        matchEdit.Value := match
        y += 56
        dlg.Add("Button", "x260 y" . y . " w70", "OK").OnEvent("Click", (*) => (
            onSave(nameEdit.Value, matchEdit.Value), dlg.Destroy()
        ))
        dlg.Add("Button", "x340 y" . y . " w70", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
        dlg.Show("w640 h" . (y + 35))
    }

    ; ========== BASIC TAB ==========
    _BuildBasicTab() {
        this._tab.UseTab(1)
        y := 40
        gui := this._gui
        cfg := this._config
        cbs := Map()

        _addCB(name, text) {
            checked := cfg.Get("Basic", name, 0) = 1
            cb := gui.Add("Checkbox", "x20 y" . y . " w300", text)
            cb.Value := checked
            y += 25
            cbs[name] := cb
        }

        labels := ["Run as Administrator", "Start with Windows", "Disable on full screen", "Monitor script changes", "Monitor settings changes"]
        for i, name in ["Admin", "StartUp", "DisableOnFullScreen", "ScriptMonitor", "SettingMonitor"]
            _addCB(name, labels[i])

        gui.Add("Text", "x20 y" . y . " w80", "Python path:")
        pyEdit := gui.Add("Edit", "x105 y" . (y-4) . " w300", this._config.Get("Basic", "Python", ""))
        y += 30
        gui.Add("Text", "x20 y" . y . " w80", "Proxy mode:")
        proxyDDL := gui.Add("DropDownList", "x105 y" . (y-4) . " w150", ["Off", "System", "Force"])
        proxyVal := this._config.Get("Basic", "Proxy", "")
        proxyDDL.Choose(proxyVal = "system" ? 2 : proxyVal = "force" ? 3 : 1)
        y += 28
        gui.Add("Text", "x20 y" . y . " w120", "Message Level:")
        level := this._config.Get("Notify", "MsgLevel", 1)
        notifyDDL := gui.Add("DropDownList", "x150 y" . (y-4) . " w150", ["Debug (all)", "Normal", "Warn only", "Disable"])
        notifyDDL.Choose(level + 1)

        this._basicControls := {pyEdit: pyEdit, proxyDDL: proxyDDL, notifyDDL: notifyDDL, checkboxes: cbs}
    }

    ; ========== BACKGROUND TAB ==========
    _BuildBackgroundTab() {
        this._tab.UseTab(4)
        lv := this._gui.Add("ListView", "x20 y40 w560 h320 -Multi Grid", ["Name", "Command"])
        this._listViews["Background"] := lv
        for k, v in this._config.GetSection("Background")
            lv.Add(, k, v)
        lv.ModifyCol(1, 120)
        lv.ModifyCol(2, 420)

        this._gui.Add("Button", "x20 y370 w70", "Edit").OnEvent("Click", (*) => this._EditBgItem(lv))
        this._gui.Add("Button", "x100 y370 w70", "Delete").OnEvent("Click", (*) => this._DeleteBgItem(lv))
        this._gui.Add("Button", "x180 y370 w70", "Add").OnEvent("Click", (*) => this._AddBgItem(lv))
    }

    ; ========== TRANS TAB ==========
    _BuildTransTab() {
        this._tab.UseTab(5)
        y := 40
        this._gui.Add("Text", "x20 y" . y . " w120", "Source Language:")
        srcEdit := this._gui.Add("Edit", "x150 y" . (y-4) . " w100", this._config.Get("Trans", "SourceLanguage", "en"))
        y += 30
        this._gui.Add("Text", "x20 y" . y . " w120", "Target Language:")
        dstEdit := this._gui.Add("Edit", "x150 y" . (y-4) . " w100", this._config.Get("Trans", "TargetLanguage", "zh-CN"))
        y += 30
        this._gui.Add("Text", "x20 y" . y . " w120", "MyMemory Key:")
        keyEdit := this._gui.Add("Edit", "x150 y" . (y-4) . " w250", this._config.Get("Trans", "MyMemoryKey", ""))
        y += 30
        this._gui.Add("Text", "x20 y" . y . " w560", "Email → 50000 chars/day. API key → register at mymemory.translated.net")
        this._transControls := {srcEdit: srcEdit, dstEdit: dstEdit, keyEdit: keyEdit}
    }

    _EditBgItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        name := lv.GetText(row, 1)
        cmd := lv.GetText(row, 2)
        this._BgEditDialog(name, cmd, (newName, newCmd) => lv.Modify(row, , newName, newCmd))
    }

    _DeleteBgItem(lv) {
        row := lv.GetNext()
        if row = 0
            return
        lv.Delete(row)
    }

    _AddBgItem(lv) {
        this._BgEditDialog("", "", (newName, newCmd) => lv.Add(, newName, newCmd))
    }

    _BgEditDialog(name, cmd, onSave) {
        dlg := Gui(, "Edit Background Task")
        dlg.SetFont("s10", "Segoe UI")
        dlg.Add("Text", "x10 y12 w70", "Name:")
        dlg.Add("Text", "x10 y42 w70", "Command:")
        nameEdit := dlg.Add("Edit", "x80 y10 w400", name)
        cmdEdit := dlg.Add("Edit", "x80 y40 w400", cmd)
        dlg.Add("Button", "x140 y75 w70", "OK").OnEvent("Click", (*) => (
            onSave(nameEdit.Value, cmdEdit.Value), dlg.Destroy()
        ))
        dlg.Add("Button", "x220 y75 w70", "Cancel").OnEvent("Click", (*) => dlg.Destroy())
        dlg.Show("w500 h110")
    }

    ; ========== SAVE / RELOAD ==========
    _OnSave(*) {
        ; Save Basic checkboxes
        cb := this._basicControls.checkboxes
        for name in ["Admin", "StartUp", "DisableOnFullScreen", "ScriptMonitor", "SettingMonitor"]
            this._config.Set("Basic", name, cb[name].Value ? 1 : 0)
        this._config.Set("Basic", "Python", this._basicControls.pyEdit.Value)
        proxyVal := this._basicControls.proxyDDL.Value
        this._config.Set("Basic", "Proxy", proxyVal = "Off" ? "" : proxyVal = "System" ? "system" : "force")

        ; Save Message Level (in Basic tab)
        levelMap := Map("Debug (all)", 0, "Normal", 1, "Warn only", 2, "Disable", 3)
        this._config.Set("Notify", "MsgLevel", levelMap.Get(this._basicControls.notifyDDL.Value, 1))

        ; Save Trans
        tc := this._transControls
        this._config.Set("Trans", "SourceLanguage", tc.srcEdit.Value)
        this._config.Set("Trans", "TargetLanguage", tc.dstEdit.Value)
        this._config.Set("Trans", "MyMemoryKey", tc.keyEdit.Value)

        ; Save Keymap, Switch, Background from ListViews
        for sec in ["Keymap", "Switch", "Background"]
            this._SaveListViewSection(sec)

        this._config.Save()
        Engine.Instance.OnHotReload()
        Engine.Instance.notify.Info("Settings saved")
    }

    _OnReload(*) {
        Engine.Instance.OnHotReload()
    }

    _SaveListViewSection(section) {
        if this._config.HasSection(section)
            this._config._data.Delete(section)
        lv := this._listViews[section]
        row := 0
        while row := lv.GetNext(row) {
            k := lv.GetText(row, 1)
            v := lv.GetText(row, 2)
            if k != ""
                this._config.Set(section, k, v)
        }
    }
}
