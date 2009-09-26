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
