class PythonRunner {
    static Run(code) {
        python := Engine.Instance.config.Get("Basic", "Python", "python")
        if python = "" {
            Engine.Instance.notify.Warn("Python path not configured")
            return ""
        }

        rnd := Random(100000, 999999)
        tmpPy := Format("{}\capslock2_py_{}.py", A_Temp, rnd)
        tmpOut := Format("{}\capslock2_py_{}.txt", A_Temp, rnd)
        tmpBat := Format("{}\capslock2_py_{}.bat", A_Temp, rnd)
        try FileDelete(tmpPy)
        try FileDelete(tmpOut)
        try FileDelete(tmpBat)
        FileAppend(code, tmpPy, "UTF-8")

        batContent := Format('@"{}" "{}" > "{}" 2>&1', python, tmpPy, tmpOut)
        FileAppend(batContent, tmpBat)
        RunWait(Format('"{}"', tmpBat), , "Hide")

        result := ""
        if FileExist(tmpOut) {
            result := FileRead(tmpOut)
            try FileDelete(tmpOut)
        }
        try FileDelete(tmpPy)
        try FileDelete(tmpBat)

        return Trim(result, "`n`r ")
    }
}
