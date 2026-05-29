class TranslateSvc {
    _proxy := ""
    _srcLang := "auto"
    _dstLang := "zh"

    __New(config) {
        this._proxy := config.Get("Trans", "GoogleProxy", "force")
        this._srcLang := config.Get("Trans", "SourceLanguage", "auto")
        this._dstLang := config.Get("Trans", "TargetLanguage", "zh")
    }

    TranslateSelected() {
        content := Helpers.GetSelectedText()
        if (content = "") {
            Helpers.OnMouseToolTip("no selection")
            return
        }
        typ := Helpers.StrType(content)
        if (typ = "word") {
            Helpers.OnMouseToolTip(this._TranslateWord(Helpers.PunctTrim(content)))
        } else {
            Helpers.OnMouseToolTip(this._TranslateSentence(content))
        }
    }

    _TranslateWord(word) {
        url := "http://www.iciba.com/word?w=" . word
        header := Map(
            "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        )
        response := Helpers.Get(url, header)
        response := StrReplace(response, "&nbsp;", " ")
        response := StrReplace(response, "&lt;", "<")
        response := StrReplace(response, "&gt;", ">")
        response := StrReplace(response, "&#x27;", "'")

        pronPat := "<li>([^<]*)<!-- -->([^<]*)(?:<img|</li>)"
        defPat := "<li><i>([^<]*)</i><div>((?:(?!div).)*)</div></li>"
        extraPat := "<li><div>((?:(?!div).)*)</div></li>"

        result := [word . "`n"]
        pos := 1
        while pos := RegExMatch(response, pronPat, &m, pos) {
            pos += StrLen(m[1])
            result.Push(m[1] . " " . m[2] . "`n")
        }
        pos := 1
        while pos := RegExMatch(response, defPat, &m, pos) {
            pos += StrLen(m[1])
            cleaned := StrReplace(StrReplace(StrReplace(m[2], "<span>", ""), "</span>", ""), "<!-- -->", "")
            result.Push(m[1] . " " . cleaned . "`n")
        }
        pos := 1
        while pos := RegExMatch(response, extraPat, &m, pos) {
            pos += StrLen(m[1])
            cleaned := StrReplace(StrReplace(StrReplace(m[1], "<span>", ""), "</span>", ""), "<!-- -->", "")
            result.Push(cleaned . "`n")
        }

        txt := ""
        for _, p in result
            txt .= p
        return txt
    }

    _TranslateSentence(text) {
        proxy := this._GetProxy()
        url := "http://translate.google.com/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl="
            . this._srcLang . "&tl=" . this._dstLang . "&q=" . text
        header := Map(
            "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        )
        response := Helpers.Get(url, header, proxy)
        try {
            jsonObj := Jxon_Load(&response)
            src := jsonObj["src"]
            trans := ""
            for _, sentence in jsonObj["sentences"]
                trans .= sentence["trans"] . "`n"

            static LANGUAGES := Map(
                "af","afrikaans","sq","albanian","am","amharic","ar","arabic",
                "hy","armenian","az","azerbaijani","eu","basque","be","belarusian",
                "bn","bengali","bs","bosnian","bg","bulgarian","ca","catalan",
                "ceb","cebuano","ny","chichewa","zh","chinese","zh-cn","chinese (simplified)",
                "zh-tw","chinese (traditional)","co","corsican","hr","croatian",
                "cs","czech","da","danish","nl","dutch","en","english",
                "eo","esperanto","et","estonian","tl","filipino","fi","finnish",
                "fr","french","fy","frisian","gl","galician","ka","georgian",
                "de","german","el","greek","gu","gujarati","ht","haitian creole",
                "ha","hausa","haw","hawaiian","iw","hebrew","hi","hindi",
                "hmn","hmong","hu","hungarian","is","icelandic","ig","igbo",
                "id","indonesian","ga","irish","it","italian","ja","japanese",
                "jw","javanese","kn","kannada","kk","kazakh","km","khmer",
                "ko","korean","ku","kurdish (kurmanji)","ky","kyrgyz","lo","lao",
                "la","latin","lv","latvian","lt","lithuanian","lb","luxembourgish",
                "mk","macedonian","mg","malagasy","ms","malay","ml","malayalam",
                "mt","maltese","mi","maori","mr","marathi","mn","mongolian",
                "my","myanmar (burmese)","ne","nepali","no","norwegian",
                "ps","pashto","fa","persian","pl","polish","pt","portuguese",
                "pa","punjabi","ro","romanian","ru","russian","sm","samoan",
                "gd","scots gaelic","sr","serbian","st","sesotho","sn","shona",
                "sd","sindhi","si","sinhala","sk","slovak","sl","slovenian",
                "so","somali","es","spanish","su","sundanese","sw","swahili",
                "sv","swedish","tg","tajik","ta","tamil","te","telugu",
                "th","thai","tr","turkish","uk","ukrainian","ur","urdu",
                "uz","uzbek","vi","vietnamese","cy","welsh","xh","xhosa",
                "yi","yiddish","yo","yoruba","zu","zulu","fil","Filipino","he","Hebrew"
            )
            srcName := LANGUAGES.Get(src, src)
            dstName := LANGUAGES.Get(this._dstLang, this._dstLang)
            return srcName . "->" . dstName . "`n" . trans
        }
        catch Error as e {
            return "Google Translate failed. May need proxy."
        }
    }

    _GetProxy() {
        if (this._proxy = "system" and Helpers.GetProxyStatus())
            return Helpers.GetProxyServer()
        else if (this._proxy = "force")
            return Helpers.GetProxyServer()
        return ""
    }
}
