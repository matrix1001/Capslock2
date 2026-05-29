RunPythonCode(code) {
    Script := A_ScriptDir . '\lib\pyrunner.py'
    tempOutput := A_Temp . "\temp_output_" . A_TickCount . ".txt"
    ;tempOutput := "d:\temp_output.txt"

    ; 转换 code 为单行并转义特殊字符
    code := StrReplace(code, "\", "\\")
    code := StrReplace(code, "`"", "\`"")
    code := StrReplace(code, "`r`n", "\n")
    code := StrReplace(code, "`n", "\n")
    code := StrReplace(code, "`r", "\n")
    code := "`"" . code . "`""

    cmd := HyperSettings["Basic"]["Python"] . " " . Script . " " . tempOutput . " " . code
    ;MsgBox(cmd)
    RunWait(cmd, ,'hide')

    if FileExist(tempOutput) {
        try 
        {
            output := FileRead(tempOutput, "UTF-8")
            FileDelete(tempOutput)
            return output
        }
        catch
            return "读取输出失败"
    } else
        return "运行失败或无输出"
}


