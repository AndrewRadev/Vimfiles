"    Author:  Fvw (vimtexhappy@gmail.com)
"             Auto complete popup plugin
"   Version:  v01.07
"   Created:  2010-04-25
"   License:  Copyright (c) 2001-2010, Fvw
"             GNU General Public License version 2 for more details.
"     Usage:  Put this file in your VIM plugins dir
"             Add usr type:
"             let g:usrPP= {}
"             let g:usrPP["type"] = [
"                         \ {'cmd'     : "\<c-n>",
"                         \  'pattern' : ['xx', 'yy'],
"                         \  'exclude' : ['zz'],
"                         \ },
"                         \{item2}
"                         \{item3}
"                         \]
"             "*" type would be append to every type.
"
"             Use :PopupType type change now popupType
"pp_it.vim: {{{1
if v:version < 700 || exists("g:loadedPPIT")
    finish
endif
let g:loadedPPIT= 1


"let s:keys    = [
            "\ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
            "\ 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
            "\ 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
            "\ 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
            "\ 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2',
            "\ '3', '4', '5', '6', '7', '8', '9', '-', '_', '~', '^',
            "\ '.', ',', ':', '!', '#', '=', '%', '$', '@', '<', '>',
            "\ '/', '\']


autocmd BufEnter,BufRead * call <SID>RunPP()
autocmd FileType * call <SID>RunPP()
amenu <silent> &Popup.Run :call <SID>RunPP()<CR>
amenu <silent> &Popup.Clr :call <SID>StopPP()<CR>

command PopupRun call <SID>RunPP()
command PopupClr call <SID>StopPP()

command -nargs=? -complete=custom,g:PPTypes PopupType call <SID>SetPPTypes(<q-args>)

"Map {{{1
function! s:Map()
    silent! inoremap <silent> <buffer> <expr> <c-x><c-o>
                \ (pumvisible()?'<c-y>':'').
                \ '<c-x><c-o><c-r>=<SID>FixPP("OmniTip")<cr>'
    silent! inoremap <silent> <buffer> <expr> <c-n>
                \ (pumvisible()?'<c-n>':
                \ '<c-n><c-r>=<SID>FixPP("CtrlNTip")<cr>')
    silent! inoremap <silent> <buffer> <expr> <c-b>
                \ (pumvisible()?'<c-y>':'').
                \ '<c-n><c-r>=<SID>FixPP("CtrlNTip")<cr>'

    "use \<c-r> insert fix char
    inoremap <silent> <buffer> <Plug>PopupFix <c-r>=<SID>FixPP()<cr>

    "for key in s:keys
        "if maparg(key, 'i') == ""
            "exec "silent! inoremap <silent> <buffer> ".key." ".key.
                        "\ "\<c-r>=\<SID>CheckPP()\<cr>"
        "endif
    "endfor
    au! CursorHoldI * :call <SID>CheckPP()

    if maparg('i', 'n') == ""
        nnoremap <silent> <buffer> i i<c-r>=<SID>CheckPP()<cr>
    endif
    if maparg('a', 'n') == ""
        nnoremap <silent> <buffer> a a<c-r>=<SID>CheckPP()<cr>
    endif
    if has("autocmd") && exists("+omnifunc")
        if &omnifunc == ""
            setlocal omnifunc=syntaxcomplete#Complete
        endif
    endif
endfunction

function! s:Unmap()
    "for key in s:keys
        "if maparg(key, 'i') =~ 'CheckPP'
            "exec "silent! iunmap <buffer> ".key
        "endif
    "endfor
    silent! iunmap <buffer> <c-x><c-o>
    silent! iunmap <buffer> <c-n>
    silent! iunmap <buffer> <c-p>
    silent! iunmap <buffer> <c-b>
    silent! iunmap <buffer> <Plug>FixPP
    silent! nunmap <buffer> i
    silent! nunmap <buffer> a
    au! CursorHoldI *
endfunction

"GetSid {{{1
fun! s:GetSid()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfun

"StopPP {{{1
fun! s:StopPP()
    call s:Unmap()
    exec "silent! aunmenu &Popup.Type"
endfun

"RunPP {{{1
fun! s:RunPP()
    let b:PPType  = []
    let b:PPLastFail  = {}
    "--------------------------------------------------
    if exists("g:PopupDelayTime")
        exec "set updatetime=".g:PopupDelayTime
    endif
    "idx == 0  -> no fail
    call g:SetPPTip("")
    call s:UpdateLastFail(0)
    call s:SetPPTypes(&ft)
    call s:Map()
    call g:ResetPP()
endfun

"FixPP {{{1
fun! s:FixPP(...)
    return ""
    "Don't use feedkeys , because if the complete
    "very slow the feedkeys would add key after
    "some use input
    if !pumvisible()
        call g:SetPPTip("")
        return "\<c-e>"
    else
        "clean
        call s:UpdateLastFail(0)
        if a:0 == 1
            call g:SetPPTip(a:1)
        endif
        "return "\<c-p>\<down>"
        return "\<c-p>"
    endif
endfun


"CheckPP {{{1
fun! s:CheckPP()
    "--------------------------------------------------
    "ignore

    if &paste || s:isPPPause()
        return ""
    end
    let tip = g:GetPPTip()
    "skip some pumvisible tip
    "SnipTips" "SelTips" for snip plugin tab_it.vim
    if pumvisible()
                \&& (tip == "SnipTips"
                \  ||tip == "SelTips"
                \  ||tip == "CtrlNTip"
                \  ||tip == "CtrlPTip"
                \  ||tip == "OmniTip"
                \)
        return ""
    endif
    "--------------------------------------------------
    let idx = col('.')-2
    if idx >= 0
        let lstr = getline('.')[:idx]
    else
        let lstr = ''
    endif
    let i = 0
    for cpl in b:PPType
        let i += 1
        if s:IsMatch(lstr, cpl.pattern)
                    \ && !(has_key(cpl,'exclude') && s:IsMatch(lstr, cpl.exclude))
            if (pumvisible() && tip == "AutoTip".i)
                "This match already pumvisible
                return ""
            endif
            if s:IsLastFail(i)
                "Update
                call s:UpdateLastFail(i)
                return ""
            endif
            if pumvisible()
                call feedkeys("\<c-e>", 'n')
            endif
            if cpl.cmd == "\<c-n>" || cpl.cmd == "\<c-x>\<c-o>"
                call feedkeys(cpl.cmd, 'n')
            else
                "<C-R>= can't remap use feedkeys can remap
                call feedkeys(cpl.cmd, 'm')
            end
            call g:SetPPTip("AutoTip".i)
            "Set first , Clear in FixPP if pum ok"
            call s:UpdateLastFail(i)
            "Use plug for silent
            call feedkeys("\<Plug>PopupFix", 'm')
            return ""
        endif
    endfor
    return ""
endfun
fun! s:IsMatch(str, list)
    for val in a:list
        if val != "" && a:str =~ '\m\C'.val.'$'
            return 1
        endif
    endfor
    return 0
endfun
fun! s:UpdateLastFail(idx)
    let b:PPLastFail['col'] = col('.')
    let b:PPLastFail['idx'] = a:idx
endfun
fun! s:IsLastFail(idx)
    if col('.') - b:PPLastFail['col'] == 1
                \ && b:PPLastFail['idx'] == a:idx
        return 1
    endif
    return 0
endfun

"Tip {{{1
function! g:SetPPTip(w)
    let b:PPTip = a:w
endfun
function! g:GetPPTip()
    return b:PPTip
endfun
"pp pause{{{1
function! g:PausePP()
    let b:ppPasue += 1
endfun
function! g:ContinuePP()
    let b:ppPasue -= 1
endfun
function! g:ResetPP()
    let b:ppPasue = 0
endfun
function! s:isPPPause()
    return (b:ppPasue > 0)
endfun

"ExtendType: {{{1
fun! s:ExpendType(list1, list2)
    for item in a:list2
        if !s:HasCmd(a:list1, item)
            call add(a:list1, deepcopy(item))
        endif
    endfor
endfun
fun! s:HasCmd(list, chk)
    for item in a:list
        if item.cmd == a:chk.cmd
            return 1
        endif
    endfor
    return 0
endfun

"MakeAllPopup: {{{1
fun! s:MakePPs()
    let s:allPPs = {}
    if exists("g:usrPP") && type(g:usrPP) ==  type({})
        let s:allPPs = deepcopy(g:usrPP)
        for type in keys(s:defaultPP)
            if !has_key(s:allPPs, type)
                let s:allPPs[type] = deepcopy(s:defaultPP[type])
            else
                call s:ExpendType(s:allPPs[type], s:defaultPP[type])
            endif
        endfor
    else
        let s:allPPs = deepcopy(s:defaultPP)
    endif

    exec "silent! aunmenu &Popup.Type"
    for type in keys(s:allPPs)
        silent exec 'amenu <silent> &Popup.Type.'.escape(type, '.').
                    \ " :call \<SID>SetPPTypes('".type."')\<CR>"
    endfor
endfun

"SetPPTypes{{{1
fun! s:SetPPTypes(...)
    let type = a:0 > 0 ? a:1 : &ft
    let b:PPType = []
    if has_key(s:allPPs, type)
        let b:PPType = deepcopy(s:allPPs[type])
    endif
    if type != '*' && has_key(s:allPPs, "*")
        call s:ExpendType(b:PPType, s:allPPs['*'])
    endif
endfun
fun! g:PPTypes(A,L,P)
    return join(keys(s:allPPs), "\n")
endfun

"def Popup: {{{1
let s:defaultPP = {}
let s:defaultPP["*"] = [
            \ {'cmd'     : "\<c-x>\<c-f>",
            \  'pattern' : ['/\f\{1,}'],
            \ },
            \ {'cmd'     : "\<c-n>",
            \  'pattern' : ['\k\@<!\k\{3,20}'],
            \ },
            \]
let s:defaultPP["c"] = [
            \ {'cmd'     : "\<c-x>\<c-o>",
            \  'pattern' : ['\k\.','\k->'],
            \ },
            \]
let s:defaultPP["c.gtk"] = [
            \ {'cmd'     : "\<c-x>\<c-o>",
            \  'pattern' : ['\k\.\k{0,20}','\k->\k{0,20}',
            \               'gtk_\k\{2,20}','GTK_\k\{1,20}','Gtk\k\{1,20}',
            \               'gdk_\k\{2,20}','GDK_\k\{1,20}','Gdk\k\{1,20}',
            \               'g_\k\{2,20}', 'G_\k\{1,20}'],
            \ },
            \]
let s:defaultPP["tex"] = [
            \ {'cmd'     : "\<c-n>",
            \  'pattern' : ['\\\k\{3,20}','\([\|{\)\k\{3,20}'],
            \ },
            \]
let s:defaultPP["html"] = [
            \ {'cmd'     : "\<c-x>\<c-o>",
            \  'pattern' : ['&','<','</',
            \               '<.*\s\+\k\{3,20}','<.*\k\+\s*="\k\{3,20}'],
            \ },
            \]
let s:defaultPP["css"] = [
            \ {'cmd'     : "\<c-n>",
            \  'pattern' : ['\k\@<!\k\{3,20}'],
            \  'exclude' : ['^\s.*'],
            \ },
            \ {'cmd'     : "\<c-x>\<c-o>",
            \  'pattern' : ['^\s.*\(\k\|-\)\@<!\(\k\|-\)\{2,20}'],
            \ },
            \]
let s:defaultPP["javascript"] = [
            \ {'cmd'     : "\<c-x>\<c-o>",
            \  'pattern' : ['\k\.\k\{0,20}'],
            \ },
            \]

let s:allPPs  = {}
call s:MakePPs()
" vim: set ft=vim ff=unix fdm=marker :
