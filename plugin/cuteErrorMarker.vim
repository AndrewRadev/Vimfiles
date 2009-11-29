"=============================================================================
" What Is This: Display marks at lines with compilation error.
" File: cuteErrorMarker.vim
" Author: Vincent Berthoux <twinside@gmail.com>
" Last Change: 2009 june 28
" Version: 1.3
" Thanks:
" Require:
"   set nocompatible
"     somewhere on your .vimrc
" Usage:
"      :MarkErrors
"        Place markers near line from the error list
"      :CleanupMarkErrors
"        Remove all the markers
"       show calendar in normal mode
"      :RemoveErrorMarkersHook
"        Remove the autocommand for sign placing
"      :make
"        Place marker automatically by default
" ChangeLog:
"     * 1.3.2:- Changed loading of files using globpath()
"     * 1.3.1:- Changed data retrievel function to getqflist().
"     * 1.3  :- Taking into account "Documents and Settings" folder...
"             - Adding icons source from $VIM or $VIMRUNTIME
"             - Checking the nocompatible option (the only one required)
"     * 1.2  :- Fixed problems with subdirectory
"             - Warning detection is now case insensitive
"     * 1.1  :- Bug fix when make returned only an error
"             - reduced flickering by avoiding redraw when not needed.
"     * 1.0  : Original version
" Additional:
"     * if you don't want the automatic placing of markers
"       after a make, you can define :
"       let g:cuteerrors_no_autoload = 1
" Thanks:
"       - A. S. Budden for the globpath function
"       - Benoît Pierre for pointing the function getqflist() and
"         providing a patch.
"       - Yazilim Duzenleci for stressing the plugin and forcing
"         me to make it more general.
"
if exists("g:__CUTEERRORMARKER_VIM__")
    finish
endif
let g:__CUTEERRORMARKER_VIM__ = 1

"======================================================================
"           Configuration checking
"======================================================================
if &compatible
    echom 'Cute Error Marker require the nocompatible option, loading aborted'
    echom "To fix it add 'set nocompatible' in your .vimrc file"
    finish
endif

if has("win32")
    let s:ext = '.ico'
else
    let s:ext = '.png'
endif

let s:path = globpath( &rtp, 'signs/err' . s:ext )
if s:path == ''
    echom "Cute Error Marker can't find icons, plugin not loaded" 
    finish
endif

"======================================================================
"           Plugin data
"======================================================================
let s:signId = 33000
let s:signCount = 0

exec 'sign define errhere text=[X icon=' . escape( globpath( &rtp, 'signs/err' . s:ext ), ' \' )
exec 'sign define warnhere text=/! icon=' . escape( globpath( &rtp, 'signs/warn' . s:ext ), ' \' )

fun! PlaceErrorMarkersHook() "{{{
    augroup cuteerrors
        "au !
        au QuickFixCmdPre make call CleanupMarkErrors()
        au QuickFixCmdPost make call MarkErrors()
    augroup END
endfunction "}}}

fun! RemoveErrorMarkersHook() "{{{
    augroup cuteerrors
        au!
    augroup END
endfunction "}}}

fun! s:SelectClass( error ) "{{{
    if a:error =~ '\cwarning'
        return 'warnhere'
    else
        return 'errhere'
    endif
endfunction "}}}

fun! MarkErrors() "{{{
    let errList = getqflist()

    for error in errList
        if error.valid
            let matchedBuf = error.bufnr

            if matchedBuf >= 0
                let s:signCount = s:signCount + 1
                let id = s:signId + s:signCount
                let errClass = s:SelectClass( error.text )

                let toPlace = 'sign place ' . id
                            \ . ' line=' . error.lnum
                            \ . ' name=' . errClass
                            \ . ' buffer=' . matchedBuf
                exec toPlace
            endif
        endif
    endfor

    " If we have placed some markers
    if s:signCount > 0
        redraw!
    endif
endfunction "}}}

fun! CleanupMarkErrors() "{{{
    let i = s:signId + s:signCount

    " this if is here to avoid redraw if un-needed
    if i > s:signId
        while i > s:signId
            let toRun = "sign unplace " . i
            exec toRun
            let i = i - 1
        endwhile

        let s:signCount = 0
        redraw!
    endif
endfunction "}}}

if !exists("g:cuteerrors_no_autoload")
    call PlaceErrorMarkersHook()
endif

command! MarkErrors call MarkErrors()
command! CleanupMarkErrors call CleanupMarkErrors()

