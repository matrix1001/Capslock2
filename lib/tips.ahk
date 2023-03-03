OnMouseToolTip(msg, delay := 1000)
{
    MouseGetPos(&X, &Y)
    ToolTip(msg, X-5, Y-5)
    SetTimer(tooltipchk, delay)
    tooltipchk()
    {
        if not MouseIsOver("ahk_class tooltips_class32")
        {
            ToolTip()
        }
        else
        {
            SetTimer(tooltipchk, 0)
            SetTimer(tooltipchk, delay)
        }
    }  
}
