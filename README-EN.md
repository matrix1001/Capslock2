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

<div style="background:#f0f0f0;color:#333;padding:14px;border:1px solid #ccc;border-radius:4px;font-family:Segoe UI,sans-serif;font-size:13px;line-height:1.6;max-width:540px;margin:14px 0">
  <div style="display:flex;gap:0;margin-bottom:10px">
    <span style="background:#fff;color:#333;padding:4px 12px;border:1px solid #ccc;border-bottom-color:#fff;border-radius:3px 3px 0 0;font-size:12px;font-weight:600">Basic</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Keymap</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Switch</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Background</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Trans</span>
  </div>
  <div style="margin:6px 0">
    <label style="display:flex;align-items:center;gap:6px;margin:5px 0"><input type="checkbox" checked disabled> Run as Administrator</label>
    <label style="display:flex;align-items:center;gap:6px;margin:5px 0"><input type="checkbox" checked disabled> Start with Windows</label>
    <label style="display:flex;align-items:center;gap:6px;margin:5px 0"><input type="checkbox" checked disabled> Disable on full screen</label>
    <label style="display:flex;align-items:center;gap:6px;margin:5px 0"><input type="checkbox" checked disabled> Monitor script changes</label>
    <label style="display:flex;align-items:center;gap:6px;margin:5px 0"><input type="checkbox" checked disabled> Monitor settings changes</label>
  </div>
  <div style="margin:8px 0;display:flex;align-items:center;gap:8px">
    <span>Python path:</span>
    <span style="background:#fff;padding:2px 8px;border:1px solid #ccc;flex:1">C:\path\to\python.exe</span>
  </div>
  <div style="margin:8px 0;display:flex;align-items:center;gap:8px">
    <span>Proxy mode:</span>
    <span style="background:#fff;padding:2px 8px;border:1px solid #ccc">Off&nbsp;&nbsp;▾</span>
  </div>
  <div style="margin:8px 0;display:flex;align-items:center;gap:8px">
    <span>Message Level:</span>
    <span style="background:#fff;padding:2px 8px;border:1px solid #ccc">Normal&nbsp;&nbsp;▾</span>
  </div>
  <div style="margin-top:12px;display:flex;gap:6px">
    <span style="background:#e1e1e1;padding:3px 16px;border:1px solid #ccc;border-radius:2px;font-size:12px">Save</span>
    <span style="background:#e1e1e1;padding:3px 16px;border:1px solid #ccc;border-radius:2px;font-size:12px">Cancel</span>
    <span style="background:#e1e1e1;padding:3px 16px;border:1px solid #ccc;border-radius:2px;font-size:12px">Reload Script</span>
  </div>
</div>

<!-- Keymap tab -->
<div style="background:#f0f0f0;color:#333;padding:14px;border:1px solid #ccc;border-radius:4px;font-family:Segoe UI,sans-serif;font-size:13px;line-height:1.6;max-width:540px;margin:14px 0">
  <div style="display:flex;gap:0;margin-bottom:10px">
    <span style="padding:4px 12px;font-size:12px;color:#666">Basic</span>
    <span style="background:#fff;color:#333;padding:4px 12px;border:1px solid #ccc;border-bottom-color:#fff;border-radius:3px 3px 0 0;font-size:12px;font-weight:600">Keymap</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Switch</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Background</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Trans</span>
  </div>
  <table style="width:100%;border-collapse:collapse;font-size:12px">
    <tr style="background:#e8e8e8"><th style="padding:4px 8px;text-align:left;border:1px solid #ccc;width:120px">Key</th><th style="padding:4px 8px;text-align:left;border:1px solid #ccc">Function</th></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">1</td><td style="padding:3px 8px;border:1px solid #ddd">QWindow(1)</td></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">h</td><td style="padding:3px 8px;border:1px solid #ddd">Send({Left})</td></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">t</td><td style="padding:3px 8px;border:1px solid #ddd">TranslateSelected</td></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">e</td><td style="padding:3px 8px;border:1px solid #ddd">Window(DirectoryOpus)</td></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">esc</td><td style="padding:3px 8px;border:1px solid #ddd">ToggleSuspend</td></tr>
  </table>
  <div style="margin-top:10px;display:flex;gap:6px">
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Edit</span>
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Delete</span>
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Add</span>
  </div>
</div>

<!-- Switch tab -->
<div style="background:#f0f0f0;color:#333;padding:14px;border:1px solid #ccc;border-radius:4px;font-family:Segoe UI,sans-serif;font-size:13px;line-height:1.6;max-width:540px;margin:14px 0">
  <div style="display:flex;gap:0;margin-bottom:10px">
    <span style="padding:4px 12px;font-size:12px;color:#666">Basic</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Keymap</span>
    <span style="background:#fff;color:#333;padding:4px 12px;border:1px solid #ccc;border-bottom-color:#fff;border-radius:3px 3px 0 0;font-size:12px;font-weight:600">Switch</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Background</span>
    <span style="padding:4px 12px;font-size:12px;color:#666">Trans</span>
  </div>
  <table style="width:100%;border-collapse:collapse;font-size:12px">
    <tr style="background:#e8e8e8"><th style="padding:4px 8px;text-align:left;border:1px solid #ccc;width:120px">Name</th><th style="padding:4px 8px;text-align:left;border:1px solid #ccc">Path / Match</th></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">Terminal</td><td style="padding:3px 8px;border:1px solid #ddd">wt.exe ahk_exe WindowsTerminal.exe ahk_class CASCADIA_HOSTING_WINDOW_CLASS</td></tr>
    <tr style="background:#fff"><td style="padding:3px 8px;border:1px solid #ddd">VSCode</td><td style="padding:3px 8px;border:1px solid #ddd">Code.exe ahk_exe Code.exe ahk_class Chrome_WidgetWin_1</td></tr>
  </table>
  <div style="margin-top:10px;display:flex;gap:6px">
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Pick Window</span>
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Edit</span>
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Delete</span>
    <span style="background:#e1e1e1;padding:3px 12px;border:1px solid #ccc;border-radius:2px;font-size:12px">Test</span>
  </div>
</div>

The Switch tab includes a **Pick Window** tool: click the button → GUI hides → click any window → all match criteria auto-filled.

## Translation Popup

Select text, press `Caps+T`:

<div style="background:#282828;padding:14px 16px;border-radius:8px;font-family:Segoe UI,sans-serif;max-width:520px;margin:16px 0;position:relative">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
    <span style="color:#c0c0c0;font-size:11px;font-weight:500">TRANSLATION</span>
    <div style="display:flex;gap:14px;align-items:center">
      <span style="color:#808080;font-size:11px">COPY</span>
      <span style="color:#808080;font-size:14px;cursor:pointer">✕</span>
    </div>
  </div>
  <div style="color:#fff;font-size:15px;line-height:1.7">
    Tomorrow will be sunny with some clouds, temperatures between 18 and 26 degrees — perfect for outdoor activities. A light jacket is recommended for the cooler evening.
  </div>
</div>

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
