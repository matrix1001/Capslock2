LANGUAGES := Map(
    "af","afrikaans",
    "sq","albanian",
    "am","amharic",
    "ar","arabic",
    "hy","armenian",
    "az","azerbaijani",
    "eu","basque",
    "be","belarusian",
    "bn","bengali",
    "bs","bosnian",
    "bg","bulgarian",
    "ca","catalan",
    "ceb","cebuano",
    "ny","chichewa",
    "zh","chinese",
    "zh-cn","chinese (simplified)",
    "zh-tw","chinese (traditional)",
    "co","corsican",
    "hr","croatian",
    "cs","czech",
    "da","danish",
    "nl","dutch",
    "en","english",
    "eo","esperanto",
    "et","estonian",
    "tl","filipino",
    "fi","finnish",
    "fr","french",
    "fy","frisian",
    "gl","galician",
    "ka","georgian",
    "de","german",
    "el","greek",
    "gu","gujarati",
    "ht","haitian creole",
    "ha","hausa",
    "haw","hawaiian",
    "iw","hebrew",
    "hi","hindi",
    "hmn","hmong",
    "hu","hungarian",
    "is","icelandic",
    "ig","igbo",
    "id","indonesian",
    "ga","irish",
    "it","italian",
    "ja","japanese",
    "jw","javanese",
    "kn","kannada",
    "kk","kazakh",
    "km","khmer",
    "ko","korean",
    "ku","kurdish (kurmanji)",
    "ky","kyrgyz",
    "lo","lao",
    "la","latin",
    "lv","latvian",
    "lt","lithuanian",
    "lb","luxembourgish",
    "mk","macedonian",
    "mg","malagasy",
    "ms","malay",
    "ml","malayalam",
    "mt","maltese",
    "mi","maori",
    "mr","marathi",
    "mn","mongolian",
    "my","myanmar (burmese)",
    "ne","nepali",
    "no","norwegian",
    "ps","pashto",
    "fa","persian",
    "pl","polish",
    "pt","portuguese",
    "pa","punjabi",
    "ro","romanian",
    "ru","russian",
    "sm","samoan",
    "gd","scots gaelic",
    "sr","serbian",
    "st","sesotho",
    "sn","shona",
    "sd","sindhi",
    "si","sinhala",
    "sk","slovak",
    "sl","slovenian",
    "so","somali",
    "es","spanish",
    "su","sundanese",
    "sw","swahili",
    "sv","swedish",
    "tg","tajik",
    "ta","tamil",
    "te","telugu",
    "th","thai",
    "tr","turkish",
    "uk","ukrainian",
    "ur","urdu",
    "uz","uzbek",
    "vi","vietnamese",
    "cy","welsh",
    "xh","xhosa",
    "yi","yiddish",
    "yo","yoruba",
    "zu","zulu",
    "fil","Filipino",
    "he","Hebrew",
)

TranslateSelected()
{
    content := GetSelectedText()
    ;MsgBox(content)
    if (content = "")
        OnMouseToolTip("nop")
    else
    {
        typ := GetStrType(content)
        if (typ = 'word')
        {
            word := PunctTrim(content)
            OnMouseToolTip(CgdictTranslate(word))
        }
        else if (typ = 'sentence')
        {
            src := HyperSettings["Trans"]["SourceLanguage"]
            dst := HyperSettings["Trans"]["TargetLanguage"]
            OnMouseToolTip(GoogleTranslate(content, src, dst))
        }
            
    }
}

CgdictTranslate(word)
{
    url := Format("http://www.iciba.com/word?w={}", word)
    header := Map(
        "User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
    )
    response := HttpGet(url, header)
    response := StrReplace(response, "&nbsp;", " ")
    response := StrReplace(response, "&lt;", "<")
    response := StrReplace(response, "&gt;", ">")
    response := StrReplace(response, "&#x27;", "'")
    pron_pattern := "<li>([^<]*)<!-- -->([^<]*)(?:<img|</li>)"
    pattern := "<li><i>([^<]*)</i><div>((?:(?!div).)*)</div></li>"
    pattern2 := "<li><div>((?:(?!div).)*)</div></li>"
    result := [word . "`n"]
    pos := 1
    while pos:=RegExMatch(response, pron_pattern, &match, pos)
    {
        pos := pos + StrLen(match[1])
        result.push(Format("{} {}`n", match[1], match[2]))
    }
    ; add trans
    pos := 1
    while pos:=RegExMatch(response, pattern, &match, pos)
    {
        pos := pos + StrLen(match[1])
        match2_real := StrReplace(match[2], "<span>", "")
        match2_real := StrReplace(match2_real, "</span>", "")
        match2_real := StrReplace(match2_real, "<!-- -->", "")
        result.push(Format("{} {}`n", match[1], match2_real))
    }
    pos := 1
    while pos:=RegExMatch(response, pattern2, &match, pos)
    {
        pos := pos + StrLen(match[1])
        match_real := StrReplace(match[1], "<span>", "")
        match_real := StrReplace(match_real, "</span>", "")
        match_real := StrReplace(match_real, "<!-- -->", "")
        result.push(Format("{}`n", match_real))
    }
    txt := ""
    for idx, par in result
        txt .= par
    return txt
}

GoogleTranslate(content, src := "auto", dst := "zh")
{
    proxy := HyperSettings["Trans"]["GoogleProxy"]
    url := Format("http://translate.google.com/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl={1}&tl={2}&q={3}"
        , src
        , dst
        , content)
    ;msgbox(url)
    header := Map(
        "User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
    )
    if (proxy = 'system' and GetProxyStatus())
    {
        if (GetProxyStatus())
            proxy := GetProxyServer()
        else
            proxy := ""
    }
    else if (proxy = 'force')
    {
        proxy := GetProxyServer()
    }
    response := HttpGet(url, header, proxy)
    try
    {
        ;msgbox (response)
        json_obj := Jxon_Load(&response)
        src := json_obj["src"]
        trans := ""
        orig := ""
        origs := []
        for value, sentence in json_obj["sentences"]
        {
            trans .= sentence["trans"] . "`n"
            if not origs.Has(sentence["orig"])
            {
                origs.push(sentence["orig"])
                orig .= sentence["orig"] . " "
            }
            
        }
        ;trans := json_obj.sentences[1].trans
        ;orig := json_obj.sentences[1].orig

        result := Map("src",LANGUAGES[src], "dst",LANGUAGES[dst], "trans",trans, "orig",orig)
        msg := Format("{1}->{2}`n{3}", result["src"], result["dst"], result["trans"])
        return msg
    }
    catch Error as e
    {
        ;SplashText("ERROR: GoogleTrans Failed. `nurl: " . url)
        ;ErrorMsg(e)
        return "ERROR: GoogleTrans Failed. May need proxy`nurl: " . url
    }

}