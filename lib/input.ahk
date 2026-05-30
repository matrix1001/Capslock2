class InputMgr {
    ; === State ===
    _state := "Idle"
    _capsDownTick := 0
    _keysConsumed := false
    _shortThreshold := 250

    ; === Keymap ===
    _layerCache := ""
    _parsedCache := Map()

    ; === InputHook ===
    _ih := ""

    ; === Modifier tracking ===
    _altHeld := false
    _winHeld := false

    ; === Suspend ===
    _suspend := false

    Init(config) {
        this._config := config
        this.ReloadKeymap()
        this._safetyCheckFn := this._SafetyCheck.Bind(this)
        SetTimer(this._safetyCheckFn, 500)
    }

    _RecoverStuck() {
        try this._StopInputHook()
        this._state := "Idle"
        return false
    }

    _SafetyCheck() {
        if this._state = "CapsHeld" and not GetKeyState("CapsLock", "P")
            this._RecoverStuck()
    }

    ReloadKeymap() {
        this._layerCache := ""
        this._parsedCache := Map()
    }

    ; === Entry points (called from hotkeys) ===
    OnCapsDown() {
        this._SuppressNativeBehavior()
        if this._suspend
            return
        if this._config.Get("Basic", "DisableOnFullScreen", 1) = 1
            and WindowMgr.IsFullScreen("A") and not WindowMgr.IsDesktop("A")
            return
        if this._state = "CapsHeld"
            return
        this._capsDownTick := A_TickCount
        this._keysConsumed := false
        this._altHeld := false
        this._winHeld := false
        this._state := "CapsHeld"
        this._layerCache := ""
        this._StartInputHook()
    }

    OnCapsUp() {
        if this._state != "CapsHeld"
            return
        try this._StopInputHook()
        this._state := "Idle"
        this._layerCache := ""

        if this._IsShortPress() and not this._keysConsumed
            this._ToggleCapsLock()
    }

    OnWheel(direction) {
        if this._state != "CapsHeld" or this._suspend
            return
        this._TryDispatch(direction)
    }

    IsCapturing {
        get {
            if this._state != "CapsHeld"
                return false
            if not GetKeyState("CapsLock", "P")
                return this._RecoverStuck()
            return true
        }
    }
    IsSuspended() => this._suspend
    Suspend() {
        this._suspend := true
        TraySetIcon("icon/capslock2-suspend.ico",, 1)
    }
    Resume() {
        this._suspend := false
        TraySetIcon("icon/capslock2.ico",, 1)
    }

    ; === InputHook management ===
    _StartInputHook() {
        this._ih := InputHook("V")
        this._ih.KeyOpt("{All}", "N")

        layerName := this._ResolveLayer()
        layerKeymap := this._config.GetKeymap(layerName)
        suppressed := Map()
        for keyname, _ in layerKeymap {
            baseKey := this._ExtractBaseKey(keyname)
            if baseKey = "" or suppressed.Has(baseKey)
                continue
            suppressed[baseKey] := 1
            ihKey := this._ToInputHookKey(baseKey)
            if ihKey != ""
                this._ih.KeyOpt(ihKey, "+S")
        }

        this._ih.OnKeyDown := this._OnKeyDown.Bind(this)
        this._ih.Start()
    }

    _StopInputHook() {
        if this._ih != "" {
            this._ih.Stop()
            this._ih := ""
        }
    }

    ; === InputHook callbacks ===
    _OnKeyDown(ih, vk, sc) {
        if not GetKeyState("CapsLock", "P")
            return this._RecoverStuck()
        keyname := this._ResolveKey(vk, sc)
        if keyname = "" or keyname = "CapsLock" {
            raw := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
            if raw = "LAlt" or raw = "RAlt"
                this._altHeld := true
            else if raw = "LWin" or raw = "RWin"
                this._winHeld := true
            return
        }
        this._TryDispatch(keyname)
    }

    ; === Key resolution ===
    _ResolveKey(vk, sc) {
        prefix := this._GetModifierPrefix()
        key := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
        if key = "" or key = "CapsLock"
            return ""
        static modKeys := Map("LWin",1,"RWin",1,"LAlt",1,"RAlt",1,
                              "LShift",1,"RShift",1,"LCtrl",1,"RCtrl",1)
        if modKeys.Has(key)
            return ""
        key := StrLower(key)
        static legacyMap := Map(
            "``", "backquote", "-", "minus", "=", "equal",
            "[", "lbracket", "]", "rbracket", "\", "backslash",
            ";", "semicolon", "'", "quote", ",", "comma",
            ".", "dot", "/", "slash", " ", "space",
            "`t", "tab", "`n", "enter", "backspace", "backspace"
        )
        if legacyMap.Has(key)
            key := legacyMap[key]

        if prefix != ""
            key := prefix . "_" . key
        return key
    }

    _GetModifierPrefix() {
        prefix := ""
        if this._altHeld
            prefix .= "alt"
        if this._winHeld
            prefix .= "win"
        return prefix
    }

    ; === Key name conversion for KeyOpt ===
    _ExtractBaseKey(keyname) {
        return RegExReplace(keyname, "^(alt_|win_)+")
    }

    _ToInputHookKey(baseKey) {
        static ihKeyMap := Map(
            "backquote", "{``}", "minus", "{-}", "equal", "{=}",
            "lbracket", "{[}", "rbracket", "{]}", "backslash", "{\}",
            "semicolon", "{;}", "quote", "{'}", "comma", "{,}",
            "dot", "{.}", "slash", "{/}",
            "space", "{Space}", "tab", "{Tab}", "enter", "{Enter}",
            "backspace", "{Backspace}",
            "up", "{Up}", "down", "{Down}", "left", "{Left}", "right", "{Right}",
            "pgup", "{PgUp}", "pgdn", "{PgDn}", "home", "{Home}", "end", "{End}",
            "insert", "{Insert}", "delete", "{Delete}",
            "escape", "{Esc}", "esc", "{Esc}",
            "lwin", "{LWin}", "rwin", "{RWin}",
            "lalt", "{LAlt}", "ralt", "{RAlt}",
            "lshift", "{LShift}", "rshift", "{RShift}",
            "lctrl", "{LCtrl}", "rctrl", "{RCtrl}"
        )
        if ihKeyMap.Has(baseKey)
            return ihKeyMap[baseKey]
        if RegExMatch(baseKey, "i)^[a-z0-9]$")
            return "{" . baseKey . "}"
        if RegExMatch(baseKey, "i)^f([1-9]|1[0-2])$")
            return "{" . Format("{:T}", baseKey) . "}"
        return ""
    }

    ; === Dispatch helpers ===
    _TryDispatch(keyname) {
        layerName := this._ResolveLayer()
        layerKeymap := this._config.GetKeymap(layerName)
        if layerKeymap.Has(keyname) {
            fnStr := layerKeymap[keyname]
            if fnStr = ""
                return
            this._keysConsumed := true
            this._Dispatch(fnStr)
        }
    }

    ; === Layer resolution ===
    _ResolveLayer() {
        if this._layerCache != ""
            return this._layerCache = "__none__" ? "" : this._layerCache
        exe := WinGetProcessName("A")
        if exe = ""
            return ""
        name := StrLower(StrReplace(exe, ".exe", ""))
        if this._config.HasSection("Keymap_" . name) {
            this._layerCache := name
            return name
        }
        this._layerCache := "__none__"
        return ""
    }

    ; === Dispatch ===
    _ParseAndCache(fnStr) {
        match := []
        fnName := ""
        params := []
        if not RegExMatch(Trim(fnStr), "\)$") {
            fnName := fnStr
        } else if RegExMatch(fnStr, "(\w+)\((.*)\)$", &match) {
            fnName := match[1]
            if match.Count > 1 and match[2] != ""
                params := [Trim(match[2], " `"'")]
        } else {
            return ""
        }
        result := {fnName: fnName, params: params}
        this._parsedCache[fnStr] := result
        return result
    }

    _Dispatch(fnStr) {
        if this._parsedCache.Has(fnStr) {
            cached := this._parsedCache[fnStr]
            this._RunFunc(cached.fnName, cached.params)
            return
        }
        parsed := this._ParseAndCache(fnStr)
        if parsed
            this._RunFunc(parsed.fnName, parsed.params)
    }

    _RunFunc(fnName, params) {
        SetTimer(ObjBindMethod(this, "_ExecDispatch", fnName, params), -1)
    }

    _ExecDispatch(fnName, params) {
        try
            %fnName%(params*)
        catch Error as e
            Engine.Instance.notify.Error(
                Format("{1}`nLine: {2}`nExtra: {3}", e.Message, e.Line, e.Extra),
                fnName)
    }

    ; === CapsLock control ===
    _ToggleCapsLock() {
        SetCapsLockState(GetKeyState("CapsLock", "T") = 1 ? "AlwaysOff" : "AlwaysOn")
    }

    _SuppressNativeBehavior() {
        Send("{Blind}{vk07}")
    }

    _IsShortPress() {
        return (A_TickCount - this._capsDownTick) < this._shortThreshold
    }
}
