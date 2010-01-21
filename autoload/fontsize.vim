" Autoload portion of plugin/fontsize.vim.
" Maintainer:   Michael Henry (vim at drmikehenry.com)
" License:      This file is placed in the public domain.

" Font examples from http://vim.wikia.com/wiki/VimTip632

" Regex values for each platform split guifont into three
" sections (\1, \2, and \3 in capturing parentheses):
"
" - prefix
" - size (possibly fractional)
" - suffix (possibly including extra fonts after commas)

" gui_gtk2: Courier\ New\ 11
let fontsize#regex_gtk2 = '\(.\{-} \)\(\d\+\)\(.*\)'

" gui_photon: Courier\ New:s11
let fontsize#regex_photon = '\(.\{-}:s\)\(\d\+\)\(.*\)'

" gui_kde: Courier\ New/11/-1/5/50/0/0/0/1/0
let fontsize#regex_kde = '\(.\{-}\/\)\(\d\+\)\(.*\)'

" gui_x11: -*-courier-medium-r-normal-*-*-180-*-*-m-*-*
" TODO For now, just taking the first string of digits.
let fontsize#regex_x11 = '\(.\{-}-\)\(\d\+\)\(.*\)'

" gui_other: Courier_New:h11:cDEFAULT
let fontsize#regex_other = '\(.\{-}:h\)\(\d\+\)\(.*\)'

if has("gui_gtk2")
    let s:regex = fontsize#regex_gtk2
elseif has("gui_photon")
    let s:regex = fontsize#regex_photon
elseif has("gui_kde")
    let s:regex = fontsize#regex_kde
elseif has("x11")
    let s:regex = fontsize#regex_x11
else
    let s:regex = fontsize#regex_other
endif

function! fontsize#encodeFont(font)
    if has("iconv") && exists("g:fontsize#encoding")
        let encodedFont = iconv(a:font, &enc, g:fontsize#encoding)
    else
        let encodedFont = a:font
    endif
    return encodedFont
endfunction

function! fontsize#decodeFont(font)
    if has("iconv") && exists("g:fontsize#encoding")
        let decodedFont = iconv(a:font, g:fontsize#encoding, &enc)
    else
        let decodedFont = a:font
    endif
    return decodedFont
endfunction

function! fontsize#getSize(font)
    let decodedFont = fontsize#decodeFont(a:font)
    if match(decodedFont, s:regex) != -1
        " Add zero to convert to integer.
        let size = 0 + substitute(decodedFont, s:regex, '\2', '')
    else
        let size = 0
    endif
    return size
endfunction

function! fontsize#setSize(font, size)
    let decodedFont = fontsize#decodeFont(a:font)
    if match(decodedFont, s:regex) != -1
        let newFont = substitute(decodedFont, s:regex, '\1' . a:size . '\3', '')
    else
        let newFont = decodedFont
    endif
    return fontsize#encodeFont(newFont)
endfunction

function! fontsize#fontString(font)
    let s = fontsize#decodeFont(a:font)
    if len(s) == 0
        let s = "Must :set guifont; :help 'guifont'"
    elseif match(s, s:regex) == -1
        let s = "Bad guifont=" . s
    else
        let s = fontsize#getSize(s) . ": " . s
    endif
    let maxFontLen = 55
    if len(s) > maxFontLen
        let s = s[:maxFontLen - 4] . "..."
    endif
    return s
endfunction

function! fontsize#display()
    redraw
    sleep 100m
    echo fontsize#fontString(&guifont) . " (+/= - 0 ! q CR SP)"
endfunction

function! fontsize#begin()
    call fontsize#display()
endfunction

function! fontsize#quit()
    echo fontsize#fontString(&guifont) . " (Done)"
endfunction

function! fontsize#ensureDefault()
    if ! exists("g:fontsize#defaultSize")
        let g:fontsize#defaultSize = 0
    endif
    if g:fontsize#defaultSize == 0
        let g:fontsize#defaultSize = fontsize#getSize(&guifont)
    endif
endfunction

function! fontsize#default()
    call fontsize#ensureDefault()
    let &guifont = fontsize#setSize(&guifont, g:fontsize#defaultSize)
    let &guifontwide = fontsize#setSize(&guifontwide, g:fontsize#defaultSize)
    call fontsize#display()
endfunction

function! fontsize#setDefault()
    let g:fontsize#defaultSize = fontsize#getSize(&guifont)
endfunction

function! fontsize#inc()
    call fontsize#ensureDefault()
    let newSize = fontsize#getSize(&guifont) + 1
    let &guifont = fontsize#setSize(&guifont, newSize)
    let &guifontwide = fontsize#setSize(&guifontwide, newSize)
    call fontsize#display()
endfunction

function! fontsize#dec()
    call fontsize#ensureDefault()
    let newSize = fontsize#getSize(&guifont) - 1
    if newSize > 0
        let &guifont = fontsize#setSize(&guifont, newSize)
        let &guifontwide = fontsize#setSize(&guifontwide, newSize)
    endif
    call fontsize#display()
endfunction

" vim: sts=4 sw=4 tw=80 et ai:
