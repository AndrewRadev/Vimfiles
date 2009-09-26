" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/tassert.vim	[[[1
62
" tassert.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-02-21.
" @Last Change: 2009-02-22.
" @Revision:    0.0.98

let s:save_cpo = &cpo
set cpo&vim


" :nodoc:
function! tassert#Comment(line1, line2, bang) "{{{3
    let assertCP = getpos('.')
    let tassertSR = @/
    call s:CommentRegion(1, a:line1, a:line2)
    exec 'silent '. a:line1.','. a:line2 .'s/\C^\(\s*\)\(TAssert\)/\1" \2/ge'
    if !empty(a:bang)
        call tlog#Comment(a:line1, a:line2)
    endif
    let @/ = tassertSR
    call setpos('.', assertCP)
endf


" :nodoc:
function! tassert#Uncomment(line1, line2, bang) "{{{3
    let assertCP = getpos('.')
    let tassertSR = @/
    call s:CommentRegion(0, a:line1, a:line2)
    exec 'silent '. a:line1.','. a:line2 .'s/\C^\(\s*\)"\s*\(TAssert\)/\1\2/ge'
    if !empty(a:bang)
        call tlog#Uncomment(a:line1, a:line2)
    endif
    let @/ = tassertSR
    call setpos('.', assertCP)
endf


fun! s:CommentRegion(mode, line1, line2)
    exec a:line1
    let prefix = a:mode ? '^\s*' : '^\s*"\s*'
    let tb = search(prefix.'TAssertBegin\>', 'bc', a:line1)
    while tb
        let te = search(prefix.'TAssertEnd\>', 'W', a:line2)
        if te
            if a:mode
                silent exec tb.','.te.'s/^\s*/\0" /'
            else
                silent exec tb.','.te.'s/^\(\s*\)"\s*/\1/'
            endif
            let tb = search(prefix.'TAssertBegin\>', 'W', a:line2)
        else
            throw 'tAssert: Missing TAssertEnd below line '. tb
        endif
    endwh
endf


let &cpo = s:save_cpo
unlet s:save_cpo
autoload/tlog.vim	[[[1
123
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
doc/tassert.txt	[[[1
305
*tAssert.txt*           Simple Assertions & Logging
                        Thomas Link (micathom AT gmail com?subject=vim)


This plugin defines a command |:TAssert| that takes an expression as 
argument and throws an exception if this expression evaluates to 
|empty()|. You can insert these comments throughout your code whenever 
something could potentially go wrong. The exception is then thrown right 
where the problem occurs. You could think of it as a poor man's 
design-by-contract substitute.

One goal of this plugin is to allow users to quickly switch on or off 
assertions depending on the context. This can be done either by:

    1. Turning assertions off so that they are not evaluated. This can 
       be achieved by setting g:TASSERT to 0 or by calling the command 
       |:TAssertOff|.

    2. Commenting out assertions in the current buffer by calling the 
       commmand |:TAssertComment|.


Example: >

    fun! Test(a, b)
        TAssertType a:a, 'string'
        TAssertType a:b, 'number'
        TAssert !empty(a:a)
        return repeat(a:a, a:b)
    endf

NOTE: The |:TAssertType| command requires the spec.vim plugin.


                                                    *tAssert-logging*
Logging:~

TAssert also includes a few convenience commands for logging -- see 
|:TLog|.

                                                    *g:TLOG*
The variable g:TLOG controls where messages are written to:

    echom ... Print messages in the echo area.
    file  ... Print messages to a file; syntax "file:FILENAME"
    Decho ... Print messages via Decho (vimscript#642)


                                                    *tAssert-install*
Install:~

Edit the vba file and type: >

    :so %

See :help vimball for details. If you have difficulties or use vim 7.0, 
please make sure, you have the current version of vimball (vimscript 
#1502) installed.

See also |tassert-macros|.


                                                    *tAssert-redistribute*
Compatibility:~

If you want to redistribute files containing assertions but don't want 
to have people install this plugin, insert this close to the top of 
your file: >

    if exists(':TAssert')
        exec TAssertInit()
    else
        command! -nargs=* -bang TAssert :
        command! -nargs=* -bang TAssertBegin :
        command! -nargs=* -bang TAssertEnd :
    endif

Alternatively, use the |:TAssertComment| command.


========================================================================
Contents~

        :TAssert ............... |:TAssert|
        :TAssertType ........... |:TAssertType|
        :TAssertOn ............. |:TAssertOn|
        :TAssertOff ............ |:TAssertOff|
        :TAssertComment ........ |:TAssertComment|
        :TAssertUncomment ...... |:TAssertUncomment|
        IsA .................... |IsA()|
        IsNumber ............... |IsNumber()|
        IsString ............... |IsString()|
        IsFuncref .............. |IsFuncref()|
        IsList ................. |IsList()|
        IsDictionary ........... |IsDictionary()|
        IsException ............ |IsException()|
        IsError ................ |IsError()|
        IsEqual ................ |IsEqual()|
        IsNotEqual ............. |IsNotEqual()|
        IsEmpty ................ |IsEmpty()|
        IsNotEmpty ............. |IsNotEmpty()|
        IsMatch ................ |IsMatch()|
        IsNotMatch ............. |IsNotMatch()|
        IsExistent ............. |IsExistent()|
        :TLog .................. |:TLog|
        :TLogTODO .............. |:TLogTODO|
        :TLogDBG ............... |:TLogDBG|
        :TLogStyle ............. |:TLogStyle|
        :TLogVAR ............... |:TLogVAR|
        :TLogOn ................ |:TLogOn|
        :TLogOff ............... |:TLogOff|
        :TLogBufferOn .......... |:TLogBufferOn|
        :TLogBufferOff ......... |:TLogBufferOff|
        :TLogComment ........... |:TLogComment|
        :TLogUncomment ......... |:TLogUncomment|
        tlog#Comment ........... |tlog#Comment()|
        tlog#Uncomment ......... |tlog#Uncomment()|
        tlog#Log ............... |tlog#Log()|
        tlog#Debug ............. |tlog#Debug()|
        tlog#Style ............. |tlog#Style()|
        tlog#Var ............... |tlog#Var()|
        tlog#Display_echo ...... |tlog#Display_echo()|
        tlog#Display_echom ..... |tlog#Display_echom()|
        tlog#Display_file ...... |tlog#Display_file()|
        tlog#Display_Decho ..... |tlog#Display_Decho()|


========================================================================
plugin/07tassert.vim~

                                                    *:TAssert*
TAssert[!] {expr}
    Test that an expression doesn't evaluate to something |empty()|. 
    With [!] failures are logged according to the setting of 
    |g:tAssertLog|.

                                                    *:TAssertType*
TAssertType EXPRESSION, TYPE
    Check if EXPRESSION is of a certain TYPE (see |IsA()|).
    
    This command requires macros/tassert.vim to be loaded.

                                                    *:TAssertOn*
:TAssertOn
    Switch assertions on and reload the plugin.

                                                    *:TAssertOff*
:TAssertOff
    Switch assertions off and reload the plugin.

                                                    *:TAssertComment*
:TAssertComment
    Comment TAssert* commands and all lines between a TAssertBegin 
    and a TAssertEnd command.

                                                    *:TAssertUncomment*
:TAssertUncomment
    Uncomment TAssert* commands and all lines between a TAssertBegin 
    and a TAssertEnd command.


========================================================================
macros/tassert.vim~


                                                    *tassert-macros*
As of version 1.0, the Is*() functions moved from the main file to 
macros/tassert.vim. In order to have them available in your code, add 
this statement to your |vimrc| file: >

    runtime macros/tassert.vim
<

                                                    *IsA()*
IsA(expr, type)

                                                    *IsNumber()*
IsNumber(expr)

                                                    *IsString()*
IsString(expr)

                                                    *IsFuncref()*
IsFuncref(expr)

                                                    *IsList()*
IsList(expr)

                                                    *IsDictionary()*
IsDictionary(expr)

                                                    *IsException()*
IsException(expr)

                                                    *IsError()*
IsError(expr, expected)

                                                    *IsEqual()*
IsEqual(expr, expected)

                                                    *IsNotEqual()*
IsNotEqual(expr, expected)

                                                    *IsEmpty()*
IsEmpty(expr)

                                                    *IsNotEmpty()*
IsNotEmpty(expr)

                                                    *IsMatch()*
IsMatch(expr, expected)

                                                    *IsNotMatch()*
IsNotMatch(expr, expected)

                                                    *IsExistent()*
IsExistent(expr)


========================================================================
plugin/05tlog.vim~

                                                    *:TLog*
:TLog MESSAGE

                                                    *:TLogTODO*
:TLogTODO MESSAGE
    Mark as "Not yet implemented".

                                                    *:TLogDBG*
:TLogDBG EXPRESSION
    Expression must evaluate to a string.

                                                    *:TLogStyle*
:TLogStyle STYLE EXPRESSION
    Expression must evaluate to a string.

                                                    *:TLogVAR*
:TLogVAR VAR1, VAR2 ...
    Display variable names and their values.
    This command doesn't work with script-local variables.

                                                    *:TLogOn*
:TLogOn
    Enable logging.

                                                    *:TLogOff*
:TLogOff
    Disable logging.

                                                    *:TLogBufferOn*
:TLogBufferOn
    Enable logging for the current buffer.

                                                    *:TLogBufferOff*
:TLogBufferOff
    Disable logging for the current buffer.

                                                    *:TLogComment*
:TLogComment
    Comment out all tlog-related lines in the current buffer which should 
    contain a vim script.

                                                    *:TLogUncomment*
:TLogUncomment
    Re-enable all tlog-related statements.


========================================================================
autoload/tlog.vim~

                                                    *tlog#Comment()*
tlog#Comment(line1, line2)

                                                    *tlog#Uncomment()*
tlog#Uncomment(line1, line2)

                                                    *tlog#Log()*
tlog#Log(text)

                                                    *tlog#Debug()*
tlog#Debug(text)

                                                    *tlog#Style()*
tlog#Style(style, text)

                                                    *tlog#Var()*
tlog#Var(caller, var, ...)

                                                    *tlog#Display_echo()*
tlog#Display_echo(text)

                                                    *tlog#Display_echom()*
tlog#Display_echom(text)

                                                    *tlog#Display_file()*
tlog#Display_file(text)

                                                    *tlog#Display_Decho()*
tlog#Display_Decho(text)




vim:tw=78:fo=tcq2:isk=!-~,^*,^|,^":ts=8:ft=help:norl:
macros/tassert.vim	[[[1
142
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/vimtlib/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-03-07.
" @Last Change: 2009-03-07.
" @Revision:    7

if &cp || exists("loaded_macros_tassert")
    finish
endif
let loaded_macros_tassert = 1

let s:save_cpo = &cpo
set cpo&vim

" :doc:
"                                                     *tassert-macros*
" As of version 1.0, the Is*() functions moved from the main file to 
" macros/tassert.vim. In order to have them available in your code, add 
" this statement to your |vimrc| file: >
" 
"     runtime macros/tassert.vim


let s:types = ['number', 'string', 'funcref', 'list', 'dictionary']

fun! s:CheckMethod(dict, prototype, method)
    if a:method == 'data'
        return 1
    endif
    let m = a:prototype[a:method]
    if type(m) == 0 && !m
        return 1
    endif
    return has_key(a:dict, a:method)
endf

fun! s:CheckType(expr, type)
    let Val  = a:expr
    if type(a:type) == 3
        for t in a:type
            let rv = s:CheckType(Val, t)
            if rv
                return rv
            endif
        endfor
    elseif type(a:type) == 1
        let t = index(s:types, tolower(a:type))
        if t == -1
            throw 'Unknown type: '. string(a:type)
        else
            return s:CheckType(Val, t)
        endif
    elseif type(a:type) == 4
        let type = type(Val)
        if type == 4
            let rv = !len(filter(keys(a:type), '!s:CheckMethod(Val, a:type, v:val)'))
        endif
    else
        let type = type(Val)
        let rv   = type == a:type
    endif
    return rv
endf

fun! IsA(expr, type)
    return s:CheckType(a:expr, a:type)
endf

fun! IsNumber(expr)
    return s:CheckType(a:expr, 0)
endf

fun! IsString(expr)
    return s:CheckType(a:expr, 1)
endf

fun! IsFuncref(expr)
    return s:CheckType(a:expr, 2)
endf

fun! IsList(expr)
    return s:CheckType(a:expr, 3)
endf

fun! IsDictionary(expr)
    return s:CheckType(a:expr, 4)
endf

fun! IsException(expr)
    try
        call eval(a:expr)
        return ''
    catch
        return v:exception
    endtry
endf

fun! IsError(expr, expected)
    let rv = IsException(a:expr)
    return rv =~ a:expected
endf


fun! IsEqual(expr, expected)
    " let val = eval(a:expr)
    let val = a:expr
    return val == a:expected
endf

fun! IsNotEqual(expr, expected)
    let val = eval(a:expr)
    return val != a:expected
endf

fun! IsEmpty(expr)
    return empty(a:expr)
endf

fun! IsNotEmpty(expr)
    return !empty(a:expr)
endf

fun! IsMatch(expr, expected)
    let val = a:expr
    return val =~ a:expected
endf

fun! IsNotMatch(expr, expected)
    let val = a:expr
    return val !~ a:expected
endf

fun! IsExistent(expr)
    let val = a:expr
    return exists(val)
endf


let &cpo = s:save_cpo
unlet s:save_cpo
plugin/05tlog.vim	[[[1
68
" tLog.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim-tLog)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-15.
" @Last Change: 2009-03-07.
" @Revision:    0.3.159

if &cp || exists('loaded_tlog')
    finish
endif
let loaded_tlog = 100


" One of: echo, echom, file, Decho
" Format: type:args
" E.g. file:/tmp/foo.log
if !exists('g:tlogDefault')   | let g:tlogDefault = 'echom'   | endif
if !exists('g:TLOG')          | let g:TLOG = g:tlogDefault    | endif
if !exists('g:tlogBacktrace') | let g:tlogBacktrace = 2       | endif


" :display: :TLog MESSAGE
command! -nargs=+ TLog call tlog#Log(<args>)

" :display: :TLogTODO MESSAGE
" Mark as "Not yet implemented".
command! -nargs=* -bar TLogTODO call tlog#Debug(expand('<sfile>').': Not yet implemented '. <q-args>)

" :display: :TLogDBG EXPRESSION
" Expression must evaluate to a string.
command! -nargs=1 TLogDBG call tlog#Debug(expand('<sfile>').': '. <args>)

" :display: :TLogStyle STYLE EXPRESSION
" Expression must evaluate to a string.
command! -nargs=+ TLogStyle call tlog#Style(<args>)

" :display: :TLogVAR VAR1, VAR2 ...
" Display variable names and their values.
" This command doesn't work with script-local variables.
command! -nargs=+ TLogVAR call tlog#Var(expand('<sfile>'), <q-args>, <args>)
" command! -nargs=+ TLogVAR if !TLogVAR(expand('<sfile>').': ', <q-args>, <f-args>) | call tlog#Debug(expand('<sfile>').': Var doesn''t exist: '. <q-args>) | endif

" Enable logging.
command! -bar -nargs=? TLogOn let g:TLOG = empty(<q-args>) ? g:tlogDefault : <q-args>

" Disable logging.
command! -bar -nargs=? TLogOff let g:TLOG = ''

" Enable logging for the current buffer.
command! -bar -nargs=? TLogBufferOn let b:TLOG = empty(<q-args>) ? g:tlogDefault : <q-args>

" Disable logging for the current buffer.
command! -bar -nargs=? TLogBufferOff let b:TLOG = ''

" Comment out all tlog-related lines in the current buffer which should 
" contain a vim script.
command! -range=% -bar TLogComment call tlog#Comment(<line1>, <line2>)

" Re-enable all tlog-related statements.
command! -range=% -bar TLogUncomment call tlog#Uncomment(<line1>, <line2>)


finish

CHANGE LOG {{{1
see 07tAssert.vim

plugin/07tassert.vim	[[[1
146
" tAssert.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim-tAssert)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-12.
" @Last Change: 2009-03-11.
" @Revision:    807
"
" GetLatestVimScripts: 1730 1 07tAssert.vim

let s:save_cpo = &cpo
set cpo&vim

if &cp || exists("loaded_tassert")
    if !(!exists("s:assert") || g:TASSERT != s:assert)
        finish
    endif
endif
let loaded_tassert = 100


if !exists('g:TASSERT')    | let g:TASSERT = 0    | endif
if !exists('g:TASSERTLOG') | let g:TASSERTLOG = 1 | endif

if exists('s:assert')
    echom 'TAssertions are '. (g:TASSERT ? 'on' : 'off')
endif
let s:assert = g:TASSERT


if g:TASSERT

    if exists(':TLogOn') && empty(g:TLOG)
        TLogOn
    endif

    " :display: TAssert[!] {expr}
    " Test that an expression doesn't evaluate to something |empty()|. 
    " With [!] failures are logged according to the setting of 
    " |g:tAssertLog|.
    command! -nargs=1 -bang -bar TAssert 
                \ let s:assertReason = '' |
                \ try |
                \   let s:assertFailed = empty(eval(<q-args>)) |
                \ catch |
                \   let s:assertReason = v:exception |
                \   let s:assertFailed = 1 |
                \ endtry |
                \ if s:assertFailed |
                \   let s:assertReason .= ' '. <q-args> |
                \   if "<bang>" != '' |
                \     call tlog#Log(s:assertReason) |
                \   else |
                \     throw substitute(s:assertReason, '^Vim.\{-}:', '', '') |
                \   endif |
                \ endif

    " :display: TAssertType EXPRESSION, TYPE
    " Check if EXPRESSION is of a certain TYPE (see |IsA()|).
    "
    " This command requires macros/tassert.vim to be loaded.
    command! -nargs=+ -bang -bar TAssertType TAssert<bang> IsA(<args>)

else

    " :nodoc:
    command! -nargs=1 -bang -bar TAssert :
    " :nodoc:
    command! -nargs=+ -bang -bar TAssertType :

endif


if !exists(':TAssertOn')

    if exists('*fnameescape')
        let s:self_file = fnameescape(expand('<sfile>:p'))
    else
        let s:self_file = escape(expand('<sfile>:p'), " \t\n*?[{`$\\%#'\"|!<")
    endif

    " Switch assertions on and reload the plugin.
    " :read: command! -bar TAssertOn
    exec 'command! -bar TAssertOn let g:TASSERT = 1 | source '. s:self_file

    " Switch assertions off and reload the plugin.
    " :read: command! -bar TAssertOff
    exec 'command! -bar TAssertOff let g:TASSERT = 0 | source '. s:self_file

    unlet s:self_file

    " Comment TAssert* commands and all lines between a TAssertBegin 
    " and a TAssertEnd command.
    command! -range=% -bar -bang TAssertComment call tassert#Comment(<line1>, <line2>, "<bang>")

    " Uncomment TAssert* commands and all lines between a TAssertBegin 
    " and a TAssertEnd command.
    command! -range=% -bar -bang TAssertUncomment call tassert#Uncomment(<line1>, <line2>, "<bang>")

end


let &cpo = s:save_cpo
unlet s:save_cpo
finish

CHANGE LOG {{{1

0.1: Initial release

0.2
- More convenience functions
- The convenience functions now display an explanation for a failure
- Convenience commands weren't loaded when g:TASSERT was off.
- Logging to a file & via Decho()
- TAssert! (the one with the bang) doesn't throw an error but simply 
displays the failure in the log
- s:ResolveSIDs() didn't return a string if s:assertFile wasn't set.
- s:ResolveSIDs() caches scriptnames
- Moved logging code to 00tLog.vim

0.3
- IsA(): Can take a list of types as arguments and it provides a way to 
check dictionaries against prototypes or interface definitions.
- IsExistent()
- New log-related commands: TLogOn, TLogOff, TLogBufferOn, TLogBufferOff
- Use TAssertVal(script, expr) to evaluate an expression (as 
argument to a command) in the script context.
- TAssertOn implies TLogOn
- *Comment & *Uncomment commands now take a range as argument (default: 
whole file).
- TAssertComment! & TAssertUncomment! (with [!]) also call 
TLog(Un)Comment.

0.4
- TLogVAR: take a comma-separated variable list as argument; display a 
time-stamp (if +reltime); show only the g:tlogBacktrace'th last items of 
the backtrace.

1.0
- Incompatible changes galore
- Removed :TAssertToggle, :TAssertBegin & :TAssertEnd and other stuff 
that doesn't really belong here.
- :TAssertType command (requires macros/tassert.vim)
- Moved Is*() functions to macros/tassert.vim.

