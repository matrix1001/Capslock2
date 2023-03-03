# Capslock2
基于`Autohotkey v2`编写的`Capslock`键增强工具。

[English Readme](README-EN.md)

__设计理念__
- 使用规范编程语言而不是杂乱的脚本（例如`Autohotkey v1.1`）
- 做`Autohotkey`擅长的事情（例如`Listary`做的更好的，就不要做重复工作）
- 满足各类效率需求

__特色__
- 多线程支持
- 简易文本配置
- 程序员友好的快捷键位
- 程序启动/窗口切换
- 单词/句子翻译
- 系统代理设置
- 后台任务管理
- `Python`脚本支持

# 使用说明
## 安装
- 安装`Autohotkey v2`
- 下载解压或者使用`git clone`
- 启动`capslock2.ahk`
## 基本说明
`Capslock2`采用了按键和函数分离的设计，所有按键都是在`Settings.ini`中绑定了某个函数，你可以随时增删改（删除该文件则会重新生成默认的）。对于绑定的函数，`Capslock2`总是启动一个新的线程运行，因此不必担心某个函数卡住。举个例子，在默认设置中`Capslock+c`是`Unix`风格的复制，那么在`Settings.ini`中它其实是这样一行：
```ini
[Keymap]
c=Send(^{Insert})
```
其中`Send`是`autohotkey v2`自带的函数，用于发送按键序列，`^{Insert}`其实就是`Ctrl+Insert`按键。

如果你想按着自己的使用习惯去定制`Capslock2`，除非你是个程序员，否则你只需要部分理解`Settings.ini`中各个区块、键值的含义。
## 固定键位
`Capslock2`提供的所有键位都是以`Capslock`开头的，以下省略`Casplock`。
|按 键|功 能|
|---|---|
|短按Capslock|开关大小写|
|长按Capslock|不做任何事|
|esc|暂停/启动Casplock2|
|c| Unix Copy (比`ctrl+c`更好用的复制)|
|v| Unix Paste |
|h|左|
|j|下|
|k|上|
|l|右|
|i|Home (行首)|
|o|End (行尾)|
|u|PgUp|
|p|PgDown|
|left|`Win+Ctrl+Left` (上一个虚拟桌面)|
|right|`Win+Ctrl+Right`|
|up|音量加|
|down|音量减|
|鼠标滚轮上|音量加|
|鼠标滚轮下|音量减|
|||
|数字键1至5|绑定/激活/最小化窗口|
|-|解开绑定窗口（限数字键绑定）|
|g|关闭当前窗口|
|space|窗口顶置/取消|
|tab|在同类型的窗口间切换（如两个打开不同文件的`Notepad.exe`）|
|||
|t|翻译选中的句子/单词|
|s|未完成|
|f|未完成|
|||
|alt+r|重新加载`Capslock2`|
|alt+p|开启/关闭系统代理|



## 程序启动/窗口切换
在默认的配置里面，为大家准备了一个`NotePad`的示例，正常来说只要是`Windows`用户，都能正常启动。
- 首先尝试按下`Capslock+w`，不出意外打开了记事本
- 然后再次按下`Capslock+w`，记事本最小化了
- 又再一次按下`Capslock+w`，记事本重新弹出来，注意这是同一个记事本

通过这个例子大家就很容易了解程序启动/窗口切换的逻辑了，如果需要加上你自己东西，那么请编辑`Settings.ini`:
```ini
[Keymap]
w=WindowA(NotePad)
[Switch]
NotePad=notepad.exe
```
假设需要把你的浏览器、`WindowsTerminal`、`VSCode`也给绑定到快捷键，那么像下面这样添加即可：
```ini
[Keymap]
w=WindowA(NotePad)
a=WindowB(Edge)
r=WindowB(WindowsTerminal, ahk_exe WindowsTerminal.exe)
d=WindowB(VSCode, ahk_exe Code.exe ahk_class Chrome_WidgetWin_1)
[Switch]
NotePad=notepad.exe
Edge=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
WindowsTerminal=wt.exe
VSCode=D:\Software\VSCode\Code.exe
```
注意事项：
- `WindowA`和`WindowB`的区别主要是`Activate`的方式不同，前者激活第一个找到的，后者激活最后找到的。激活/最小化的过程中，对于个别程序，可能会偶尔失效，注意使用`Autohotkey`的`window spy`工具去检查你的窗口属性，参考上面`VSCode`就是一种比较稳妥的写法。
- `[Switch]`下面的键只要不重复就行，值需要是绝对路径（或者程序在环境变量之中，如`notepad.exe`）。
- 如果程序实际运行的路径（或名称）和`[Switch]`中定义的不一样，需要自己找好名称，如上`wt.exe`运行的程序名称实际上是`WindowsTerminal.exe`。
- 对于所有`ahk_class`为`Chrome_WidgetWin_1`的程序，例如`VSCode`，则必须像上面那样写，因为这些程序很有可能带了一个`Chrome_WidgetWin_0`的不可见窗口，直接使用会导致激活了不可见的那个窗口。

### 绑定临时窗口
首先使得需要绑定的窗口处于`Active`状态，使用`Capslock+数字`绑定，目前限定数字1-5（非小键盘数字），绑定以后就可以像上面的预设窗口一样使用了，以下两种情况可以解除绑定：
- 窗口已经关闭了，再次尝试激活
- 按下`Capslock+减号`，然后松开，再输入数字1-5，即可解除对应的绑定

## 基本配置
`Admin`是设置以管理员模式启动，`StartUp`设置开机启动，`Python`非必须（但是可能影响一些基于`Python`的功能）。
```ini
[Basic]
Admin=0
DisableOnFullScreen=1
ScriptMonitor=1
SettingMonitor=1
StartUp=1
Python=/path/to/python
```
## 消息窗口
用于`Capslock2`中程序的通知，设置`MsgLevel`为0则会出现所有通知便于调试，设置为2则只会出现警告信息，设置为3则保持静默。
```ini
[Notify]
Enable=1
Max=5
MsgLevel=1
Style=slide
```
## 翻译功能
单词的翻译设定的是`cgdict`的英译中，配置中主要是关于谷歌翻译句子的，其中关于`GoogleProxy`，设置为`system`即使用系统代理，设置为`force`则强制使用系统代理（即使系统代理没有开启），这两种情况都需要你已经设置好系统代理。若无需代理请设为空值，自定义代理则直接填入代理，如`localhost:1234`。
```ini
[Trans]
GoogleProxy=force
SourceLanguage=auto
TargetLanguage=zh
```
## 系统代理
系统代理的设置方法如下：

这个方法和你在windows设置里面是等价的，预设绑定了开关系统代理键位：`Capslock+Alt+p`。
## 专业功能
普通用户请略过，以下功能主要服务于程序员。
### 后台运行程序
`Capslock2`设计了后台运行程序的功能，需要自行在`Settings.ini`中配置好。如下展示绑定`Capslock+alt+a`键到启动一个`HTTP`服务器，按下快捷键即可将服务启动（不会弹出窗口），再次按下会将其关闭。
```ini
[Keymap]
alt_a=ToggleBackgound(MyServer)
[Background]
MyServer=/path/to/http_server.exe -p 1080
```
__注意事项__
- 程序的路径不能包含空格
- 程序请带上`.exe`结尾
### Python程序支持
技术方法很简单，利用剪贴板传递代码，执行完毕后利用剪贴板输出，需要在`python`代码里面设置变量`AHK_RETURN_STR`作为最终输出。如下代码最终会弹出`test function from python: 4`。

```
test_python_code := "
(
def test(n):
    return n+2
AHK_RETURN_STR = "test function from python: {}".format(test(2))
)"

MsgBox(RunPythonCode(test_python_code))
```
### 添加你的AHK脚本
由于键、函数分离的设计，你只需要按照如下步骤即可：
- 在脚本中定义好你想用的函数，将脚本放入`lib`或者`script`目录
- 在`capslock2.ahk`中加入`#Include lib\你的脚本.ahk`
- 在`Settings.ini`里面的`[Keymap]`后面加上`你想绑定的键=你的函数(参数1,参数2)`（参数根据你的函数设计，可为空）
- 重启`Capslock2`


# 其他
## 支持与帮助
该程序首要服务于我本人的需要，因此不会耗费大量精力去做兼容等，如果遇到了难以解决的问题，并且坚持要使用`Capslock2`，请提交`issue`。

欢迎任何合理的`Pull Request`。
## 使用许可
除以下代码遵循原作者许可，其他代码仅允许个人非商业使用。
- [`lib/json.ahk`](https://github.com/cocobelgica/AutoHotkey-JSON)