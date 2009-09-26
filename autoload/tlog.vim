" tlog.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-02-21.
" @Last Change: 2009-02-22.
" @Revision:    0.0.12

let s:save_cpo = &cpo
set cpo&vim


function! tlog#Comment(line1, line2) "{{{3
    " TLogVAR a:line1, a:line2
    let tlogCP = getpos('.')
    let tlogSR = @/
    exec 'silent '. a:line1 .','. a:line2 .'s/\C^\(\s*\)\(\(call *\|exe\%[cute] *[''"]\)\?\(TLog\|tlog#\)\)/\1" \2/ge'
    let @/ = tlogSR
    call setpos('.', tlogCP)
endf


function! tlog#Uncomment(line1, line2) "{{{3
    let tlogCP = getpos('.')
    let tlogSR = @/
    exec 'silent '. a:line1 .','. a:line2 .'s/\C^\(\s*\)"\s*\(\(call *\|exe\%[cute] *[''"]\)\?\(TLog\|tlog#\)\)/\1\2/ge'
    let @/ = tlogSR
    call setpos('.', tlogCP)
endf


fun! tlog#Log(text)
    let log = s:GetLogType()
    if !empty(log)
        call tlog#Display_{log}(a:text)
        return 1
    endif
    return 0
endf

fun! tlog#Debug(text)
    return tlog#Log('DBG: '. a:text)
endf

fun! tlog#Style(style, text)
    exec ' echohl '. a:style
    let rv = tlog#Log(a:text)
    echohl NONE
    return rv
endf

fun! tlog#Var(caller, var, ...)
    let msg = ['VAR']
    if has('reltime')
        call add(msg, reltimestr(reltime()) .':')
    endif
    if g:tlogBacktrace > 0
        let caller = split(a:caller, '\.\.')
        let start  = max([0, len(caller) - g:tlogBacktrace - 1])
        let caller = caller[start : -1]
        if !empty(caller)
            call add(msg, join(caller, '..') .':')
        endif
    endif
    let var = split(a:var, '\s*,\s*')
    for i in range(1, a:0)
        let v = var[i - 1]
        if type(a:{i}) == 2
            let R = a:{i}
            call add(msg, v .'='. string(R) .';')
            unlet R
        else
            let r = a:{i}
            call add(msg, v .'='. string(r) .';')
            unlet r
        endif
    endfor
    return tlog#Log(join(msg, ' '))
    " return tlog#Log('VAR: '. a:text .' '. a:var .'='. string(a:val))
endf

fun! tlog#Display_echo(text)
    echo a:text
endf

fun! tlog#Display_echom(text)
    echom a:text
endf

fun! tlog#Display_file(text)
    let fname = s:GetLogArg()
    if fname == ''
        let fname = expand('%:r') .'.log'
    endif
    exec 'redir >> '. fname
    silent echom a:text
    redir END
endf

fun! tlog#Display_Decho(text)
    call Decho(a:text)
endf

fun! s:GetLogPref()
    return exists('b:TLOG') ? b:TLOG : g:TLOG
endf

fun! s:GetLogType()
    let log = s:GetLogPref()
    let arg = matchstr(log, '^\a\+')
    return arg
endf

fun! s:GetLogArg()
    let log = s:GetLogPref()
    let arg = matchstr(log, '^file:\zs.*$')
    return arg
endf



let &cpo = s:save_cpo
unlet s:save_cpo
