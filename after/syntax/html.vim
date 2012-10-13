if !exists("html_no_rendering")
    syn match htmlLinkLeadingWhitespace "^\s\+" contained
    syn match htmlLinkTrailingWhitespace "\s\+$" contained
    syn region htmlLink start="<a\>\_[^>]*\<href\>" end="</a>"me=e-4 contains=@Spell,htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,javaScript,@htmlPreproc,htmlLinkLeadingWhitespace,htmlLinkTrailingWhitespace

    if version >= 508 || !exists("did_html_syn_inits")
        hi def link htmlLinkLeadingWhitespace   NONE
        hi def link htmlLinkTrailingWhitespace  NONE
    endif
endif
