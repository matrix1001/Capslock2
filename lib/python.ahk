test_python_code := "
(
def test(n):
    return n+2
AHK_RETURN_STR = "test function from python: {}".format(test(2))
)"

RunPythonCode(code, timeout:=1000)
{
    old := A_Clipboard
    A_Clipboard := code
    cmd := HyperSettings["Basic"]["Python"] . " " . A_ScriptDir . '\lib\pyrunner.py'
    RunBackgroudCommand(cmd)
    timer := 0
    while (timer < timeout)
    {
        Sleep(250)
        timer := timer + 250
        if (A_Clipboard != code)
            break
    }
    result := A_Clipboard
    if (result != code)
    {
        A_Clipboard := old
        return result
    }
    else
    {
        WarningMsg("Failed to run python script.")
        return ""
    }
}