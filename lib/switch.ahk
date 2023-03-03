WindowA(name, title:="")
{
    path := HyperSettings["Switch"][name]
    if (title = "")
        title := "ahk_exe " . path
    if (not WinExist(title))
    {
        Run(path)
    }
    else if(not WinActive(title))                              
    {                                                               
        ;WinShow(title)                                    
        WinActivate(title)                                                          
    }                                                               
    else                                                            
    {                                                               
        WinMinimize()                                              
    }  
}
WindowB(name, title:="")
{
    path := HyperSettings["Switch"][name]
    if (title = "")
        title := "ahk_exe " . path
    if (not WinExist(title))
    {
        Run(path)
    }
    else if(not WinActive(title))                              
    {                                                               
        ;WinShow(title)                                    
        WinActivateBottom(title)                                                         
    }                                                               
    else                                                            
    {                                                               
        WinMinimize()                                                                      
    }  
}
WindowC(idx, opt:=1)                                                  
{ 
    static QuickWindows := Map(1,0, 2,0, 3,0, 4,0, 5,0, 6,0, 7,0, 8,0, 9,0, 0,0)
    idx := Integer(idx)
    if (opt = 0)
    {
        QuickWindows[idx] := 0
    }         
    else
    {            
        windowid := QuickWindows[idx]                                      
        if (windowid != 0)                                                   
        {                                                       
            if (not WinExist(windowid))                           
            {                                                        
                WarningMsg("Window Closed.")            
                Sleep(1500)                                                               
                QuickWindows[idx] := 0                                            
            }                                                        
            if (WinActive(windowid))                          
            {                                                        
                WinMinimize                                          
            }                                                        
            else WinActivate(windowid)                         
        }                                                            
        else 
        {
            ; avoid binding desktop
            windowid := WinGetID("A")
            windowexe := WinGetProcessName("A")
            windowclass := WinGetClass("A")
            if (windowexe = "Explorer.EXE" and windowclass = "WorkerW")
            {  
                WarningMsg(Format("Don't bind window {} to Desktop", idx))
            }
            else
            {
                QuickWindows[idx] := windowid
                InfoMsg(Format("Bind window {} to {}", idx, windowexe))
            }
        }   
    }                                                                                                
}  


WindowCClear()
{
    UserInput := InputSingleDigit()
    if UserInput != -1 ;success
    {
        WindowC(UserInput, opt:=0)                                                
        InfoMsg(Format("QuickWindow {} cleared.", UserInput))    
    }
    ; msgbox get %UserInput%       
    else
    {
        InfoMsg(Format("QuickWindow clear failed"))
    }                    
                                                               
}

WindowKill()
{
    id := WinGetID("A")
    WinKill(id)
}
WindowToggleOnTop()
{                                                       
    WinSetAlwaysOnTop(-1, "A")
    ExStyle := WinGetExStyle("A")          
    if (ExStyle & 0x8)    
        InfoMsg("Window always on top ON.")
    else
        InfoMsg("Window always on top OFF.")                                                         
}
SameWindowSwitch()
{
    class := WinGetClass("A")
    exe := WinGetProcessPath("A")   
    WinActivateBottom("ahk_class " . class . " ahk_exe " . exe)
}