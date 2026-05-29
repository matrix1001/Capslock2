class Config {
    _data := Map()
    _path := "Settings.ini"
    _settingChanged := false
    _scriptChanged := false
    _fileTimestamps := Map()

    Init() {
        if FileExist(this._path)
            this._Load()
        else
            this._GenerateAndSave()

        this._HandleStartup()
        this._HandleAdmin()
        this._StartMonitors()
    }

    ; === Access ===
    Get(section, key, default?) {
        if this._data.Has(section) and this._data[section].Has(key) {
            val := this._data[section][key]
            return IsSet(default) ? this._Coerce(val, default) : val
        }
        return IsSet(default) ? default : ""
    }

    Set(section, key, value) {
        if not this._data.Has(section)
            this._data[section] := Map()
        this._data[section][key] := value
    }

    ; === Persistence ===
    Save() {
        for sec, kv in this._data
            for key, val in kv
                IniWrite(val, this._path, sec, key)
    }

    Reload() {
        this._data := Map()
        this._Load()
        this._settingChanged := false
    }

    ; === Keymap access ===
    GetKeymap(layer := "") {
        result := Map()
        if (layer != "") {
            parent := this._GetKeymapSection("Keymap")
            for k, v in parent
                result[k] := v
        }
        section := (layer = "") ? "Keymap" : "Keymap_" . layer
        layerData := this._GetKeymapSection(section)
        for k, v in layerData
            result[k] := v
        return result
    }

    GetDefaultKeymap() {
        return this._BuildDefaults()["Keymap"]
    }

    ; === Change tracking ===
    IsSettingChanged() => this._settingChanged
    IsScriptChanged() => this._scriptChanged
    ClearChangeFlags() {
        this._settingChanged := false
        this._scriptChanged := false
    }

    ; === Internal: load/save ===
    _Load() {
        secNames := IniRead(this._path)
        for sec in StrSplit(secNames, "`n") {
            lines := StrSplit(IniRead(this._path, sec), "`n")
            for line in lines {
                line := Trim(line, "`a`t ")
                pair := StrSplit(line, "=")
                key := pair[1]
                val := pair[2]
                if not this._data.Has(sec)
                    this._data[sec] := Map()
                this._data[sec][key] := val
            }
        }
    }

    _GenerateAndSave() {
        this._data := this._BuildDefaults()
        this.Save()
    }

    _BuildDefaults() {
        d := Map()
        d["Basic"] := Map(
            "Admin", 0,
            "DisableOnFullScreen", 1,
            "ScriptMonitor", 1,
            "SettingMonitor", 1,
            "StartUp", 1,
            "Python", ""
        )
        d["Keymap"] := Map(
            "1", "WindowC(1)", "2", "WindowC(2)", "3", "WindowC(3)",
            "4", "WindowC(4)", "5", "WindowC(5)", "minus", "WindowCClear",
            "g", "WindowKill",
            "i", "Send({Blind}{Home})", "o", "Send({Blind}{End})",
            "h", "Send({Blind}{Left})", "j", "Send({Blind}{Down})",
            "k", "Send({Blind}{Up})", "l", "Send({Blind}{Right})",
            "left", "Send({Blind}#^{Left})", "right", "Send({Blind}#^{Right})",
            "s", "HyperSearch", "space", "WindowToggleOnTop",
            "t", "TranslateSelected", "tab", "SameWindowSwitch",
            "u", "Send({Blind}{PgUp})", "p", "Send({Blind}{PgDn})",
            "c", "Send({Blind}^{Insert})", "v", "Send({Blind}+{Insert})",
            "up", "Send({Blind}{Volume_Up})", "down", "Send({Blind}{Volume_Down})",
            "wheelup", "Send({Blind}{Volume_Up})", "wheeldown", "Send({Blind}{Volume_Down})",
            "alt_r", "HyperReload", "alt_p", "ToggleProxy",
            "esc", "ToggleSuspend"
        )
        d["Notify"] := Map("Enable", 1, "Max", 5, "MsgLevel", 1, "Style", "slide")
        d["Trans"] := Map("GoogleProxy", "force", "SourceLanguage", "auto", "TargetLanguage", "zh")
        d["Background"] := Map()
        d["Switch"] := Map("NotePad", "notepad.exe")
        return d
    }

    _GetKeymapSection(sectionName) {
        result := Map()
        if this._data.Has(sectionName)
            for k, v in this._data[sectionName]
                result[k] := v
        return result
    }

    ; === Type coercion ===
    _Coerce(value, default) {
        if (default is Integer) {
            try return Integer(value)
            catch
                return default
        }
        if (default is Float) {
            try return Float(value)
            catch
                return default
        }
        return value
    }

    ; === Startup + admin ===
    _HandleStartup() {
        autostartLnk := A_Startup . "\CapsLock2.lnk"
        if (this.Get("Basic", "StartUp", 1) = 1) {
            if not FileExist(autostartLnk)
                FileCreateShortcut(A_ScriptFullPath, autostartLnk, A_ScriptDir)
        } else {
            if FileExist(autostartLnk)
                FileDelete(autostartLnk)
        }
    }

    _HandleAdmin() {
        if (this.Get("Basic", "Admin", 0) = 1 and not A_IsAdmin) {
            Run("*RunAs " . A_ScriptFullPath)
            ExitApp()
        }
    }

    ; === File monitors ===
    _StartMonitors() {
        SetTimer(this._CheckSettingMtime.Bind(this), 1000)
        if (this.Get("Basic", "ScriptMonitor", 1) = 1)
            SetTimer(this._CheckScriptMtimes.Bind(this), 1000)
        if (this.Get("Basic", "SettingMonitor", 1) = 0)
            SetTimer(this._CheckSettingMtime.Bind(this), 0)
    }

    _CheckSettingMtime() {
        static lastMtime := ""
        if (lastMtime = "") {
            lastMtime := FileGetTime(this._path)
            return
        }
        current := FileGetTime(this._path)
        if (current != lastMtime) {
            this._settingChanged := true
            lastMtime := current
        }
    }

    _CheckScriptMtimes() {
        static first := true
        static timestamps := Map()

        lst := []
        for dir in ["lib", "script"] {
            if DirExist(dir)
                Loop Files, dir . "\*", "F"
                    lst.Push(dir . "\" . A_LoopFileName)
        }
        lst.Push(A_ScriptName)

        if first {
            for f in lst
                timestamps[f] := FileGetTime(f)
            first := false
            return
        }

        for f, ts in timestamps {
            if not lst.Has(f) {
                this._scriptChanged := true
                timestamps.Delete(f)
            }
        }
        for f in lst {
            current := FileGetTime(f)
            if not timestamps.Has(f) {
                this._scriptChanged := true
                timestamps[f] := current
            } else if timestamps[f] != current {
                this._scriptChanged := true
                timestamps[f] := current
            }
        }
    }
}
