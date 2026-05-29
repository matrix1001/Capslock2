class InputMgr {
    ; === State ===
    _state := "Idle"
    _capsDownTick := 0
    _keysConsumed := false
    _shortThreshold := 250

    ; === Keymap ===
    _keymap := Map()
    _layerCache := ""
    _parsedCache := Map()

    ; === InputHook ===
    _ih := ""

    ; === Suspend ===
    _suspend := false

    Init(config) {
        this._config := config
        this.ReloadKeymap()
    }

    ReloadKeymap() {
        this._keymap := this._config.GetKeymap()
        this._layerCache := ""
        this._parsedCache := Map()
    }

    ; === Entry points (called from hotkeys) ===
    OnCapsDown() {
        this._SuppressNativeBehavior()
        if this._suspend
            return
        this._capsDownTick := A_TickCount
        this._keysConsumed := false
        this._state := "CapsHeld"
        this._layerCache := ""
        this._StartInputHook()
    }

    OnCapsUp() {
        if this._state != "CapsHeld"
            return
        this._StopInputHook()
        this._state := "Idle"
        this._layerCache := ""

        if this._IsShortPress() and not this._keysConsumed
            this._ToggleCapsLock()
    }

    OnWheel(direction) {
        if this._state != "CapsHeld" or this._suspend
            return
        keyname := direction  ; "wheelup" or "wheeldown"
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

    IsCapturing => this._state = "CapsHeld"
    IsSuspended() => this._suspend
    Suspend() {
        this._suspend := true
        TraySetIcon("icon/hyper-suspend.ico",, 1)
    }
    Resume() {
        this._suspend := false
        TraySetIcon("icon/hyper.ico",, 1)
    }

    ; === InputHook management ===
    _StartInputHook() {
        this._ih := InputHook("V")              ; V = sets VisibleText + VisibleNonText = true (all pass through)
        this._ih.KeyOpt("{All}", "N")           ; notify for all keys

        ; Pre-configure suppression for all mapped keys
        layerName := this._ResolveLayer()
        layerKeymap := this._config.GetKeymap(layerName)
        suppressed := Map()                     ; dedup: only suppress each base key once
        for keyname, _ in layerKeymap {
            baseKey := this._ExtractBaseKey(keyname)
            if baseKey = "" or suppressed.Has(baseKey)
                continue
            suppressed[baseKey] := 1
            ihKey := this._ToInputHookKey(baseKey)
            if ihKey != ""
                this._ih.KeyOpt(ihKey, "+S")     ; suppress mapped keys
        }

        this._ih.OnKeyDown := this._OnKeyDown.Bind(this)
        this._ih.OnKeyUp := this._OnKeyUp.Bind(this)
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
        keyname := this._ResolveKey(vk, sc)
        if keyname = "" or keyname = "CapsLock"
            return
        layerName := this._ResolveLayer()
        layerKeymap := this._config.GetKeymap(layerName)
        if layerKeymap.Has(keyname) {
            fnStr := layerKeymap[keyname]
            if fnStr = ""                          ; empty = disabled in this layer
                return
            this._keysConsumed := true
            this._Dispatch(fnStr)
        }
        ; unmapped keys pass through (VisibleText/VisibleNonText = true)
    }

    _OnKeyUp(ih, vk, sc) {
        ; no-op
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
        if GetKeyState("LAlt", "P") or GetKeyState("RAlt", "P")
            return "alt"
        if GetKeyState("LWin", "P") or GetKeyState("RWin", "P")
            return "win"
        return ""
    }

    ; === Key name conversion for KeyOpt ===
    _ExtractBaseKey(keyname) {
        for prefix in ["alt_", "win_"] {
            if InStr(keyname, prefix) = 1
                return SubStr(keyname, StrLen(prefix) + 1)
        }
        return keyname
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

    ; === Layer resolution ===
    _ResolveLayer() {
        if this._layerCache != ""
            return this._layerCache
        exe := WinGetProcessName("A")
        if exe = ""
            return ""
        name := StrLower(StrReplace(exe, ".exe", ""))
        if this._config.GetKeymap(name).Count > 0 {
            this._layerCache := name
            return name
        }
        return ""
    }

    ; === Dispatch ===
    _Dispatch(fnStr) {
        if this._parsedCache.Has(fnStr) {
            cached := this._parsedCache[fnStr]
            this._RunFunc(cached.fn, cached.params)
            return
        }
        parsed := this._ParseAndCache(fnStr)
        if parsed
            this._RunFunc(parsed.fn, parsed.params)
    }

    _ParseAndCache(fnStr) {
        match := []
        params := []
        if not RegExMatch(Trim(fnStr), "\)$") {
            fn := %fnStr%
        } else if RegExMatch(fnStr, "(\w+)\((.*)\)$", &match) {
            fn := %match[1]%
            if match.Count > 1 and match[2] != ""
                params := StrSplit(match[2], ",", " `"'")
        } else {
            return ""
        }
        result := {fn: fn, params: params}
        this._parsedCache[fnStr] := result
        return result
    }

    _RunFunc(fn, params) {
        SetTimer(_Exec, -1)
        _Exec() {
            try
                fn(params*)
            catch Error as e
                Engine.Instance.notify.Error(e.Message . "`n`nLine: " . e.Line, fn.Name)
        }
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
