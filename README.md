<p align="center">
  <img src="icon/capslock2.ico" width="72" height="72">
</p>

<h1 align="center">Capslock2</h1>

<p align="center"><b>让键盘上最没用的键，成为你最强大的工具。</b></p>

<p align="center"><a href="README-EN.md">English Readme</a></p>

---

## 这是什么？

Capslock2 是一个 **AutoHotkey v2** 脚本，将 CapsLock 变成一个**修饰键层**——在不离开主键区的情况下完成光标导航、窗口管理、文本翻译、Python 脚本、剪贴板操作。

和其他 AHK 脚本不同，Capslock2 **没有硬编码任何一个按键**。每个按键都是 `Settings.ini` 中的一行。想让 `Caps+E` 打开 Edge 而不是 DOpus？改一行。想让 `Caps+A` 发送自定义按键而不是启动应用？改一行。不需要翻代码。

## 亮点

- **键位-函数分离** — 所有按键绑定都在 INI 里，增删改不需要碰代码
- **4 个修饰平面** — Caps、Caps+Alt、Caps+Win、Caps+Win+Alt，一个键四层快捷键
- **应用级键位覆盖** — 不同应用里同一个按键可以做不同的事
- **内置 GUI 编辑器** — 5 个标签页的设置窗口，带窗口选择器（点击目标窗口自动填入 `ahk_exe` / `ahk_class`）
- **暗色主题 UI** — 通知和翻译弹窗风格统一，简洁现代
- **翻译功能** — 选中文本按 `Caps+T`，弹出可拖动、可复制的翻译结果。使用 MyMemory API，国内可用无需代理
- **Python 集成** — `Caps+Alt+S` 测试，然后把 Python 脚本绑到任意按键
- **智能窗口切换** — 启动/激活/最小化，精确的 `ahk_exe` / `ahk_class` 匹配

### 为什么选 Capslock2？

| | Capslock2 | capslock+ | CapsLockX | Capslock-Plus-Lite |
|---|---|---|---|---|
| **按键-函数分离** | ✅ INI 完全分离 | ⚠️ 命名约定 | ⚠️ YAML | ❌ 硬编码 |
| **多修饰平面** | ✅ 4 层 | ❌ 1 层 | ❌ 1 层 | ❌ 1 层 |
| **应用级键位覆盖** | ✅ `[Keymap_app]` | ❌ | ❌ | ❌ |
| **GUI 设置编辑器** | ✅ 5 标签页 + Pick Window | ❌ | ❌ | ❌ |
| **翻译** | ✅ 国内可用，暗色弹窗 | ✅ 有道/谷歌 | ❌ | ❌ |
| **Python 集成** | ✅ 任意键调用 | ❌ | ❌ | ❌ |
| **CapsLock 防卡死** | ✅ 500ms 自检恢复 | ❌ | ❌ | ❌ |
| **短按切换大小写** | ✅ <250ms 判定 | ✅ | ✅ | ❌ |
| **文件变更监控** | ✅ 自动检测，提示重载 | ✅ | ✅ | ❌ |
| **窗口匹配方式** | `ahk_exe`+`ahk_class` 精确 | 窗口 ID（易失效） | 基本操作 | ❌ |
| **暗色 UI 主题** | ✅ 通知 + 翻译弹窗 | ❌ | ❌ | ❌ |
| **代理管理** | ✅ 注册表级系统代理 | ❌ | ❌ | ❌ |
| **后台进程管理** | ✅ 托盘一键启停 | ❌ | ❌ | ❌ |
| **代码量** | ~1700 行 | ~5000+ 行 | ~10000+ 行 | ~80 行 |
| **额外依赖** | 零（纯 AHK v2） | 零 | Rust 运行时 | 零 |

**Capslock2** = capslock+ 的现代化替代 + CapsLockX 没有的 GUI 配置 + 独家防卡死、多平面、Python 集成。

## 快速开始

```powershell
# 1. 安装 AutoHotkey v2
winget install AutoHotkey.AutoHotkey

# 2. 下载或 clone
git clone https://github.com/matrix1001/capslock2

# 3. 双击 capslock2.ahk
```

托盘出现黄色闪电图标即可使用。`Settings.ini` 自动生成，带合理默认值。按住 CapsLock 试试任何绑定键。

## 设置界面

右键托盘图标 → **Edit Settings**，打开 5 标签页的设置编辑器：

| 标签页 | 功能 |
|--------|------|
| **Basic** | 管理员模式、开机启动、全屏禁用、Python 路径、代理模式、消息级别 |
| **Keymap** | 按键 → 函数绑定列表，支持增删改 |
| **Switch** | 命名窗口定义，含 **Pick Window** 工具（点目标窗口自动填入匹配条件） |
| **Background** | 后台进程管理列表 |
| **Trans** | 翻译源语言 / 目标语言 / MyMemory API Key |

**Keymap 标签页：**

| Key | Function |
|-----|----------|
| `1` | `QWindow(1)` |
| `h` | `Send({Left})` |
| `t` | `TranslateSelected` |
| `e` | `Window(DirectoryOpus)` |
| `esc` | `ToggleSuspend` |
| ... | ... |

按钮：`Edit` `Delete` `Add`

**Switch 标签页：**

| Name | Path / Match |
|------|-------------|
| Terminal | `wt.exe ahk_exe WindowsTerminal.exe ahk_class CASCADIA_HOSTING_WINDOW_CLASS` |
| VSCode | `Code.exe ahk_exe Code.exe ahk_class Chrome_WidgetWin_1` |
| ... | ... |

按钮：`Pick Window` `Edit` `Delete` `Test`

> **Pick Window**：点击按钮 → 界面隐藏 → 点击任意窗口 → 自动填入进程路径、`ahk_exe`、`ahk_class`。再也不用猜窗口类名了。

## 翻译弹窗

选中文本，按 `Caps+T`，弹出暗色主题翻译窗口：

```
┌─ TRANSLATION ──────────── COPY  ✕ ─┐
│                                      │
│  明天天气预计晴转多云，气温 18 到     │
│  26 度，适合户外活动。出门记得带     │
│  一件薄外套，早晚温差较大。          │
│                                      │
└──────────────────────────────────────┘
```

- **拖动** — 按住 `TRANSLATION` 区域可拖动窗口
- **复制** — 点击 `COPY` 一键复制译文
- **关闭** — `Esc` 或 `✕`

使用 [MyMemory](https://mymemory.translated.net/) API —— 免费，无需 API Key，国内可用。

## 默认键位

### 光标导航

| 按键 | 功能 |
|------|------|
| `h` `j` `k` `l` | 光标 ← ↓ ↑ → |
| `i` `o` | Home / End |
| `u` `p` | Page Up / Down |
| `left` `right` | 上一个 / 下一个虚拟桌面 |

### 窗口管理

| 按键 | 功能 |
|------|------|
| `1`–`5` | 切换快速绑定窗口 |
| `Alt`+`1`–`5` | 绑定当前窗口到数字键 |
| `tab` | 同程序窗口间切换 |
| `g` | 关闭当前窗口 |
| `space` | 窗口置顶开关 |

### 功能

| 按键 | 功能 |
|------|------|
| `t` | 翻译选中文本 |
| `c` / `v` | 复制 / 粘贴（Ctrl+Ins / Shift+Ins） |
| `up` / `down` / `滚轮` | 音量控制 |

### 系统

| 按键 | 功能 |
|------|------|
| `Alt`+`R` | 重载配置/脚本 |
| `Alt`+`P` | 系统代理开关 |
| `Alt`+`S` | 测试 Python 集成 |
| `Esc` | 暂停/恢复 Capslock2 |

短按 CapsLock（<250ms，不按其他键）切换大小写状态。

## 配置

### 键位 (`[Keymap]`)

键位格式：`按键=函数名(参数)`。支持以下几种写法：

```ini
[Keymap]
; --- 发送按键（AHK 内置 Send）---
h=Send({Left})                     ; 单键：光标左移
q=Send("^+{Esc}")                  ; 组合键：Ctrl+Shift+Esc（任务管理器）
x=Send("^{x}")                     ; 剪切

; --- 启动程序（AHK 内置 Run）---
n=Run("notepad.exe")               ; 启动记事本
m=Run("explorer.exe")              ; 打开资源管理器

; --- Capslock2 内置函数 ---
t=TranslateSelected                ; 翻译选中文本
g=WindowKill                       ; 关闭当前窗口
space=WindowToggleOnTop            ; 窗口置顶开关
tab=SameWindowSwitch               ; 同应用窗口切换
esc=ToggleSuspend                  ; 暂停/恢复
alt_p=ToggleProxy                  ; 系统代理开关
alt_r=ReloadScript                 ; 重载配置

; --- 窗口切换 ---
e=Window(DirectoryOpus)            ; 启动/激活 DOpus
r=Window(WindowsTerminal)          ; 启动/激活 Terminal
a=Window(Edge)                     ; 启动/激活 Edge

; --- 快速窗口 ---
1=QWindow(1)                       ; 切换到数字键 1 绑定的窗口
alt_1=QWindowBind(1)               ; 将当前窗口绑定到数字 1

; --- 后台进程 ---
alt_o=ToggleBackground(MyServer)     ; 启动/关闭后台服务

; --- 自定义函数 ---
alt_w=CheckWeather                 ; 调用你自己写的函数（无参数）
alt_n=MyFunction(hello, 42)        ; 调用你自己写的函数（带参数）
```

### 内置函数参考

| 函数 | 说明 | 示例 |
|------|------|------|
| `Window(name)` | 启动/激活/最小化命名窗口 | `e=Window(VSCode)` |
| `QWindow(idx)` | 切换到数字键绑定的窗口 | `1=QWindow(1)` |
| `QWindowBind(idx)` | 绑定当前窗口到数字键 | `alt_1=QWindowBind(1)` |
| `WindowKill()` | 关闭当前活动窗口 | `g=WindowKill` |
| `WindowToggleOnTop()` | 切换窗口置顶状态 | `space=WindowToggleOnTop` |
| `SameWindowSwitch()` | 在同 exe+class 的窗口间循环 | `tab=SameWindowSwitch` |
| `TranslateSelected()` | 翻译选中文本（MyMemory API） | `t=TranslateSelected` |
| `ToggleProxy()` | 开关系统代理 | `alt_p=ToggleProxy` |
| `ToggleSuspend()` | 暂停/恢复 Capslock2 | `esc=ToggleSuspend` |
| `ReloadScript()` | 重载配置 / 脚本变更后完整重启 | `alt_r=ReloadScript` |
| `ToggleBackground(name)` | 启动/关闭 `[Background]` 中定义的后台程序 | `alt_o=ToggleBackground(MyServer)` |
| `Send(keys)` | AHK 内置：发送按键序列 | `h=Send({Left})` |
| `Run(target)` | AHK 内置：运行程序或打开文件 | `n=Run("notepad.exe")` |
| `PythonRunner.Run(code)` | 执行 Python 代码，返回输出字符串 | 见下方 Python 章节 |

### 添加你自己的函数

1. 打开 `lib/functions.ahk`
2. 定义一个全局函数：
```ahk
MyFunction(name, num) {
    Engine.Instance.notify.Info(name . " called with " . num)
}
```
3. 在 `Settings.ini` 的 `[Keymap]` 中添加：
```ini
alt_m=MyFunction(test, 123)
```
4. 按 `Caps+Alt+R` 重载，搞定。

函数可以写在 `lib/` 或 `script/` 目录下任意 `.ahk` 文件中。Capslock2 会自动监控这些文件的变化并提示重载。函数内可以通过 `Engine.Instance` 访问所有模块（config、notify、window、translate 等）。

### 命名窗口 (`[Switch]`)

每个条目定义如何匹配一个应用窗口：

```ini
[Switch]
; 简单程序（exe 在 PATH 中）
Notepad=notepad.exe
Taskmgr=C:\Windows\System32\taskmgr.exe

; 需要精确匹配（exe + class，避免找错窗口）
Edge=msedge.exe ahk_exe msedge.exe ahk_class Chrome_WidgetWin_1
Terminal=WindowsTerminal.exe ahk_exe WindowsTerminal.exe ahk_class CASCADIA_HOSTING_WINDOW_CLASS
VSCode=Code.exe ahk_exe Code.exe ahk_class Chrome_WidgetWin_1

; 完整路径 + 精确匹配（推荐写法，最稳妥）
DOpus=C:\Program Files\GPSoftware\Directory Opus\dopus.exe ahk_exe dopus.exe ahk_class dopus.lister
```

格式：`启动路径 ahk_exe 进程名 ahk_class 窗口类名`

- `启动路径`：用于启动程序（支持完整路径或 PATH 中的名称）
- `ahk_exe`：精确匹配进程名（如 `msedge.exe`）
- `ahk_class`：精确匹配窗口类名（防止匹配到不可见窗口）

用 Settings GUI → Switch 标签页 → **Pick Window** 按钮，点一下目标窗口就能自动填入全部三项，不用手写。

### 应用级覆盖 (`[Keymap_appname]`)

不同应用里同一个按键做不同的事：

```ini
[Keymap]
t=TranslateSelected                ; 默认：翻译

[Keymap_firefox]
t=Send(^{t})                       ; Firefox 里：新建标签页
w=Send(^{w})                       ; 关闭标签页

[Keymap_windowsterminal]
t=Send(^+{t})                      ; Terminal 里：新建标签页

[Keymap_vscode]
t=Send(^`{``})                     ; VSCode 里：切换终端
```

段名是 `Keymap_` + 进程名（去掉 `.exe`，小写）。覆盖的键会替换基础键位，未覆盖的键继续使用 `[Keymap]`。

### Python 脚本

> **注意：** Python 集成是可选功能，不配置不影响日常使用。目前仅提供基础设施，后续版本会基于此构建更多功能。

```ini
[Basic]
Python=C:\path\to\python.exe       ; 可选，不填则不启用 Python 功能
```

```ini
[Keymap]
alt_w=CheckWeather
```

```ahk
; 在 lib/functions.ahk 中
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

按 `Caps+Alt+S` 验证 Python 环境是否正常。

## 系统托盘

右键托盘图标：

- **Message Level** — 调试 / 正常 / 仅警告 / 禁用
- **Disable On Full Screen** — 全屏时自动暂停（游戏、演示）
- **Utils** — 系统代理开关、后台进程启停
- **Reload** — 配置变更后热重载，不用重启

托盘图标灰色表示已暂停，悬停显示运行状态、代理、后台进程等信息。

## 文件结构

```
capslock2.ahk             入口文件
Settings.ini              用户配置（首次运行自动生成）
lib/
  engine.ahk              应用组装 & 生命周期
  config.ahk              INI 读写、默认值、文件监控
  input.ahk               CapsLock 状态机 & 按键分发
  functions.ahk           键位适配函数（被 keymap 调用）
  window.ahk              窗口启动/激活/切换
  translate.ahk           翻译服务 & UI
  notify.ahk              暗色通知弹窗
  helpers.ahk             HTTP、代理、剪贴板工具
  tray.ahk                系统托盘图标 & 菜单
  settings_gui.ahk        5 标签页配置编辑器
  python.ahk              Python 代码执行器
  json.ahk                JSON 解析（cocobelgica/AutoHotkey-JSON）
icon/
  capslock2.ico           托盘图标（黄色闪电 — 运行中）
  capslock2-suspend.ico   托盘图标（灰色闪电 — 已暂停）
```

## 环境要求

- Windows 10 或 11
- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- Python 3.x（可选 —— 用于 `PythonRunner`）

## 许可

MIT。`lib/json.ahk` 来自 [cocobelgica/AutoHotkey-JSON](https://github.com/cocobelgica/AutoHotkey-JSON)，遵循其原始许可。
