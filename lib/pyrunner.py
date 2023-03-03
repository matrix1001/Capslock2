import win32clipboard
import os
import sys

def get_clip():
    # get clipboard data
    win32clipboard.OpenClipboard()
    data = win32clipboard.GetClipboardData()
    win32clipboard.CloseClipboard()
    return data
def set_clip(data):
    # set clipboard data
    win32clipboard.OpenClipboard()
    win32clipboard.EmptyClipboard()
    win32clipboard.SetClipboardText(data)
    win32clipboard.CloseClipboard()

code = get_clip()
AHK_RETURN_STR = ''
exec(code)
set_clip(AHK_RETURN_STR)

