<p align="center">
  <img src="icon/capslock2.ico" width="72" height="72">
</p>

<h1 align="center">Capslock2</h1>

<p align="center"><b>Turn the most useless key on your keyboard<br>into your most powerful tool.</b></p>

<p align="center"><a href="README.md">中文文档</a></p>

---

## What is Capslock2?

Capslock2 transforms your CapsLock key into a **modifier layer** — giving you cursor navigation, window management, text translation, Python scripting, and clipboard operations without leaving the home row.

Unlike other AHK scripts, Capslock2 has **zero hardcoded hotkeys**. Every key is a line in `Settings.ini`. Want `Caps+E` to open Edge instead of DOpus? Change one line. Want Caps+A to send a custom keystroke instead of launching an app? Change one line. No code diving required.

## Highlights

- **Key-function separation** — every key binding is an INI entry. Swap, add, or remove keys without touching code
- **4 modifier planes** — Caps, Caps+Alt, Caps+Win, Caps+Win+Alt. Four layers of shortcuts from one key
- **App-specific keymaps** — different keys do different things depending on which app is active
- **Built-in GUI editor** — 5-tab settings window with a window picker that auto-fills `ahk_exe` / `ahk_class`
- **Dark-themed UI** — notifications and translation popup with a clean, modern look
- **Translation** — select text, press `Caps+T`, get results in a draggable popup. Works in China (MyMemory API, no proxy needed)
- **Python integration** — `Caps+Alt+S` to test, then bind Python scripts to any key
- **Smart window switching** — launch-or-activate-or-minimize with precise `ahk_exe` / `ahk_class` matching

### Why Capslock2?

| | Capslock2 | capslock+ | CapsLockX | Capslock-Plus-Lite |
|---|---|---|---|---|
| **Key-function separation** | ✅ INI, fully decoupled | ⚠️ naming convention | ⚠️ YAML | ❌ hardcoded |
| **Modifier planes** | ✅ 4 (Caps/Alt/Win combos) | ❌ 1 | ❌ 1 | ⚠️ 2 (hardcoded) |
| **App-specific keymaps** | ✅ `[Keymap_app]` | ❌ | ❌ | ❌ |
| **GUI settings editor** | ✅ 5 tabs + Pick Window | ❌ | ❌ | ❌ |
| **Translation** | ✅ China-friendly, dark UI | ✅ Youdao/Google | ❌ | ❌ |
| **Python integration** | ✅ bind to any key | ❌ | ❌ | ❌ |
| **Multi-threaded** | ✅ SetTimer dispatch, non-blocking | ❌ direct call | ✅ Rust async | ❌ |
| **Stuck-key recovery** | ✅ 500ms self-check | ❌ | — | ❌ |
| **Tap-to-toggle CapsLock** | ✅ <250ms threshold | ✅ | ✅ | ❌ |
| **File change monitors** | ✅ auto-detect, prompt reload | ✅ | — | ❌ |
| **Window matching** | `ahk_exe`+`ahk_class` precise | window ID (stale) | basic only | ❌ |
| **Dark UI theme** | ✅ notifications + translate | ❌ | ❌ | ❌ |
| **Proxy management** | ✅ registry-level | ❌ | ❌ | ❌ |
| **Background process mgmt** | ✅ tray toggle | ❌ | ❌ | ❌ |
| **Code size** | ~1,700 lines | ~5,000+ lines | ~10,000+ lines | ~80 lines |
| **Dependencies** | zero (pure AHK v2) | zero | Rust runtime | zero |

**Capslock2** = modern capslock+ replacement + GUI config CapsLockX lacks + multi-threaded, recovery, multi-plane, and Python integration.

## Quick Start

```powershell
# 1. Install AutoHotkey v2
winget install AutoHotkey.AutoHotkey

# 2. Clone or download
git clone https://github.com/matrix1001/capslock2

# 3. Double-click capslock2.ahk
```

A yellow lightning icon appears in your tray. `Settings.ini` is auto-generated with sensible defaults. Hold CapsLock and press any bound key.

## Settings GUI

Right-click tray icon → **Edit Settings** to open the 5-tab editor:

| Tab | Contents |
|-----|----------|
| **Basic** | Admin mode, auto-start, fullscreen disable, Python path, proxy mode, message level |
| **Keymap** | Key → Function bindings list — add, edit, or delete entries |
| **Switch** | Named window definitions with **Pick Window** tool (click any window to auto-fill) |
| **Background** | Background process management list |
| **Trans** | Source/target language, MyMemory API key |

**Keymap tab:**

| Key | Function |
|-----|----------|
| `1` | `QWindow(1)` |
| `h` | `Send({Left})` |
| `t` | `TranslateSelected` |
| `e` | `Window(DirectoryOpus)` |
| `esc` | `ToggleSuspend` |
| ... | ... |

Buttons: `Edit` `Delete` `Add`

**Switch tab:**

| Name | Path / Match |
|------|-------------|
| Terminal | `wt.exe ahk_exe WindowsTerminal.exe ahk_class CASCADIA_HOSTING_WINDOW_CLASS` |
| VSCode | `Code.exe ahk_exe Code.exe ahk_class Chrome_WidgetWin_1` |
| ... | ... |

Buttons: `Pick Window` `Edit` `Delete` `Test`

> **Pick Window**: click the button → GUI hides → click any window → all match criteria auto-filled.

## Translation Popup

Select text, press `Caps+T`. A dark-themed popup appears with the translation:

```
┌─ TRANSLATION ──────────── COPY  ✕ ─┐
│                                      │
│  Tomorrow will be sunny with some    │
│  clouds, temperatures between 18     │
│  and 26 degrees — perfect for        │
│  outdoor activities.                 │
│                                      │
└──────────────────────────────────────┘
```

- **Drag** — grab the TRANSLATION header to move the window
- **Copy** — click COPY to copy the entire translation
- **Close** — Esc or ✕

Uses [MyMemory](https://mymemory.translated.net/) — free, no API key required, works in China.

## Default Keymap

### Navigation

| Keys | Action |
|------|--------|
| `h` `j` `k` `l` | Cursor ← ↓ ↑ → |
| `i` `o` | Home / End |
| `u` `p` | Page Up / Down |
| `left` `right` | Previous / Next virtual desktop |

### Window Management

| Keys | Action |
|------|--------|
| `1`–`5` | Switch to quick-bound window |
| `Alt`+`1`–`5` | Bind current window to digit |
| `tab` | Cycle same-app windows |
| `g` | Kill active window |
| `space` | Toggle always-on-top |

### Features

| Keys | Action |
|------|--------|
| `t` | Translate selected text |
| `c` / `v` | Copy / Paste (Ctrl+Ins / Shift+Ins) |
| `up` / `down` / `wheel` | Volume control |

### System

| Keys | Action |
|------|--------|
| `Alt`+`R` | Reload config / script |
| `Alt`+`P` | Toggle system proxy |
| `Alt`+`S` | Test Python integration |
| `Esc` | Suspend / Resume Capslock2 |

Tap CapsLock alone (no other key, <250ms) to toggle the actual CapsLock state.

## Configuration

### Keymap (`[Keymap]`)

Format: `key=FunctionName(args)`. Supports these patterns:

```ini
[Keymap]
; --- Send keystrokes (AHK built-in Send) ---
h=Send({Left})                     ; single key: cursor left
q=Send("^+{Esc}")                  ; combo: Ctrl+Shift+Esc (Task Manager)

; --- Launch programs (AHK built-in Run) ---
n=Run("notepad.exe")               ; open Notepad
m=Run("explorer.exe")              ; open Explorer

; --- Capslock2 built-in functions ---
t=TranslateSelected                ; translate selected text
g=WindowKill                       ; kill active window
space=WindowToggleOnTop            ; toggle always-on-top
tab=SameWindowSwitch               ; cycle same-app windows
esc=ToggleSuspend                  ; suspend/resume
alt_p=ToggleProxy                  ; toggle system proxy
alt_r=ReloadScript                 ; reload config

; --- Window switching ---
e=Window(DirectoryOpus)            ; launch/activate DOpus
r=Window(WindowsTerminal)          ; launch/activate Terminal

; --- Quick windows ---
1=QWindow(1)                       ; switch to window bound to digit 1
alt_1=QWindowBind(1)               ; bind current window to digit 1

; --- Background processes ---
alt_o=ToggleBackground(MyServer)    ; start/stop a background service

; --- Custom functions ---
alt_w=CheckWeather                 ; your own function (no args)
alt_n=MyFunction(hello, 42)        ; your own function (with args)
```

### Built-in Functions

| Function | Description | Example |
|----------|-------------|---------|
| `Window(name)` | Launch / activate / minimize named window | `e=Window(VSCode)` |
| `QWindow(idx)` | Switch to quick-bound window | `1=QWindow(1)` |
| `QWindowBind(idx)` | Bind current window to digit | `alt_1=QWindowBind(1)` |
| `WindowKill()` | Close the active window | `g=WindowKill` |
| `WindowToggleOnTop()` | Toggle always-on-top | `space=WindowToggleOnTop` |
| `SameWindowSwitch()` | Cycle windows of same exe+class | `tab=SameWindowSwitch` |
| `TranslateSelected()` | Translate selected text (MyMemory API) | `t=TranslateSelected` |
| `ToggleProxy()` | Toggle system proxy on/off | `alt_p=ToggleProxy` |
| `ToggleSuspend()` | Suspend / resume Capslock2 | `esc=ToggleSuspend` |
| `ReloadScript()` | Reload config or full restart if scripts changed | `alt_r=ReloadScript` |
| `ToggleBackground(name)` | Start/stop a background process defined in `[Background]` | `alt_o=ToggleBackground(MyServer)` |
| `Send(keys)` | AHK built-in: send keystrokes | `h=Send({Left})` |
| `Run(target)` | AHK built-in: run a program or open a file | `n=Run("notepad.exe")` |
| `PythonRunner.Run(code)` | Execute Python code, returns output string | See Python section below |

### Adding Your Own Functions

1. Open `lib/functions.ahk`
2. Define a global function:
```ahk
MyFunction(name, num) {
    Engine.Instance.notify.Info(name . " called with " . num)
}
```
3. Add to `Settings.ini` under `[Keymap]`:
```ini
alt_m=MyFunction(test, 123)
```
4. Press `Caps+Alt+R` to reload.

Functions can be placed in any `.ahk` file under `lib/` or `script/`. Capslock2 monitors these directories and prompts a reload when files change. Inside your function, access any module via `Engine.Instance` (config, notify, window, translate, etc.).

### Named Windows (`[Switch]`)

Each entry defines how to match an application window:

```ini
[Switch]
; Simple app (exe in PATH)
Notepad=notepad.exe
Taskmgr=C:\Windows\System32\taskmgr.exe

; Precise matching (exe + class, avoids phantom windows)
Edge=msedge.exe ahk_exe msedge.exe ahk_class Chrome_WidgetWin_1
Terminal=WindowsTerminal.exe ahk_exe WindowsTerminal.exe ahk_class CASCADIA_HOSTING_WINDOW_CLASS
VSCode=Code.exe ahk_exe Code.exe ahk_class Chrome_WidgetWin_1

; Full path + precise matching (recommended)
DOpus=C:\Program Files\GPSoftware\Directory Opus\dopus.exe ahk_exe dopus.exe ahk_class dopus.lister
```

Format: `LaunchPath ahk_exe ProcessName ahk_class WindowClass`

- `LaunchPath` — used to start the app (full path or PATH-accessible name)
- `ahk_exe` — exact process name for window matching
- `ahk_class` — exact window class (prevents matching invisible windows)

Use Settings GUI → Switch tab → **Pick Window** — click any window to auto-fill all three fields.

### App-Specific Overrides (`[Keymap_appname]`)

Same key, different behavior per application:

```ini
[Keymap]
t=TranslateSelected                ; default: translate

[Keymap_firefox]
t=Send(^{t})                       ; Firefox: new tab
w=Send(^{w})                       ; close tab

[Keymap_windowsterminal]
t=Send(^+{t})                      ; Terminal: new tab

[Keymap_vscode]
t=Send(^`{``})                     ; VSCode: toggle terminal
```

Section name is `Keymap_` + process name (without `.exe`, lowercase). Overridden keys replace the base; unmapped keys fall through to `[Keymap]`.

### Python Scripts

> **Note:** Python integration is optional — all core features work without it. It provides infrastructure for future script-based features.

```ini
[Basic]
Python=C:\path\to\python.exe       ; optional, leave blank to skip Python support
```

```ini
[Keymap]
alt_w=CheckWeather
```

```ahk
; In lib/functions.ahk
CheckWeather() {
    code := "
    (
import requests
r = requests.get('https://wttr.in/Beijing?format=3')
print(r.text)
    )"
    result := PythonRunner.Run(code)
    Engine.Instance.notify.Info(result)
}
```

Press `Caps+Alt+S` to verify your Python setup.

## System Tray

Right-click the tray icon for:

- **Message Level** — Debug / Normal / Warn Only / Disable
- **Disable On Full Screen** — auto-pause when gaming or presenting
- **Utils** — system proxy toggle, background process management
- **Reload** — apply config changes without restarting

Tray icon turns gray when suspended. Hover for status details.

## File Structure

```
capslock2.ahk             Entry point
Settings.ini              User config (auto-generated)
lib/
  engine.ahk              App assembly & lifecycle
  config.ahk              INI load/save, defaults, file monitors
  input.ahk               CapsLock state machine & key dispatch
  functions.ahk           Adapter functions (called from keymap)
  window.ahk              Window activate/launch/switch
  translate.ahk           Translation service & UI
  notify.ahk              Dark-themed notification popups
  helpers.ahk             HTTP, proxy, clipboard utilities
  tray.ahk                System tray icon & menu
  settings_gui.ahk        5-tab configuration editor
  python.ahk              Python code runner
  json.ahk                JSON parser (cocobelgica/AutoHotkey-JSON)
icon/
  capslock2.ico           Tray icon (yellow lightning — active)
  capslock2-suspend.ico   Tray icon (gray lightning — suspended)
```

## Requirements

- Windows 10 or 11
- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- Python 3.x (optional — for `PythonRunner`)

## License

MIT. `lib/json.ahk` is from [cocobelgica/AutoHotkey-JSON](https://github.com/cocobelgica/AutoHotkey-JSON) and follows its original license.
