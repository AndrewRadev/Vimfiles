" File:        cmdline_completion.vim
" Author:      K1n9Ti9er <ljh575@gmail.com>
" Last Change: April 15 , 2011
" Version:     0.02
"
" Description: This script let you can use CTRL-P/N to complete 
"              word in cmdline mode just like in insert mode.
"
"              You can use other keys instead of <C-P/N> like 
"              this : 
"                  cmap <C-J> <Plug>CmdlineCompletionBackward
"                  cmap <C-K> <Plug>CmdlineCompletionForward
"
" Install:     Drag this file into vim plugin directory.
"           
"

if exists("loaded_cmdline_completion") || &cp || version < 700
    finish
endif

let loaded_cmdline_completion = 1

"""""""""""""""""""""""""""""""""""""""""""""
" map key
"
if !hasmapto('<Plug>CmdlineCompletionBackward','c')
    cmap <unique> <silent> <C-P> <Plug>CmdlineCompletionBackward
endif

if !hasmapto('<Plug>CmdlineCompletionForward','c')
    cmap <unique> <silent> <C-N> <Plug>CmdlineCompletionForward
endif

cnoremap <silent> <Plug>CmdlineCompletionBackward <C-\>e<SID>CmdlineCompletion(1)<CR>
cnoremap <silent> <Plug>CmdlineCompletionForward  <C-\>e<SID>CmdlineCompletion(0)<CR>

"""""""""""""""""""""""""""""""""""""""""""""
" auto completion function ,
" return new cmdline with matched word
function! s:CmdlineCompletion(backword)

    let cmdline = getcmdline()
    let index = match(cmdline, '\w\+$')
    let cmd = strpart(cmdline, 0, index)

    " Not a word , skip completion
    if index < 0 
        return cmdline
    endif

    " s:vars initial if first time or changed cmdline.
    if !exists("b:cc_newcmdline") || cmdline != b:cc_newcmdline
        let b:cc_word_prefix = strpart(cmdline, index)
        let b:cc_word_list = [b:cc_word_prefix]
        let b:cc_word_index = 0
        let b:cc_newcmdline = "" 
        let b:cc_pos_forward = [0,0]
        let b:cc_pos_backward = [0,0]
        let b:cc_search_status = 1
    endif

    "
    if a:backword
        let b:cc_word_index -= 1
    else
        let b:cc_word_index += 1
    endif

    " try to search new word if index out of list range with cc_search_status
    if b:cc_search_status && ( b:cc_word_index < 0 
                \ || b:cc_word_index >= len(b:cc_word_list))
        let save_cursor = getpos('.')
        let b:cc_search_status = s:CmdlineSearch(a:backword)
        call setpos('.', save_cursor)
    endif

    " correct index depend on cc_search_status
    if b:cc_search_status
        if b:cc_word_index < 0 
            let b:cc_word_index = 0 
        endif
    else
        if b:cc_word_index < 0 
            let b:cc_word_index = len(b:cc_word_list) - 1
        elseif b:cc_word_index >= len(b:cc_word_list)
            let b:cc_word_index = 0
        endif
    endif

    " get word from list
    let word = get(b:cc_word_list, b:cc_word_index, b:cc_word_prefix)

    " new cmdline
    let b:cc_newcmdline = cmd . word

    " overcome map silent
    call feedkeys(" \<bs>")

    return  b:cc_newcmdline

endfunction


"""""""""""""""""""""""""""""""""""""""""""""
" search completion matched word, 
" return 0 if match none, else return 1 .
function! s:CmdlineSearch(backward)

    let position = a:backward ? b:cc_pos_backward : b:cc_pos_forward

    " set last search position
    call cursor(position)

    " search ...
    let pattern = '\<' . b:cc_word_prefix . '\w\+\>'
    let flag = a:backward ? 'web' : 'we'

    " loop search until match unique or none
    let position = searchpos(pattern, flag)
    while position != [0,0]

        if a:backward
            let b:cc_pos_backward = position
        else
            let b:cc_pos_forward = position
        endif

        if b:cc_pos_forward == [0,0] || b:cc_pos_backward == [0,0]
            " store first match position
            let b:cc_pos_forward = position
            let b:cc_pos_backward = position
        elseif b:cc_pos_forward == b:cc_pos_backward
            " wrapscan around the whole file
            return 0
        endif

        " get matched word under cursor
        let word = expand("<cword>")

        " add to list if not exists
        if count(b:cc_word_list, word) == 0 
            if a:backward
                call insert(b:cc_word_list, word)
            else
                call add(b:cc_word_list, word)
            endif
            return 1
        endif

        " search again
        let position = searchpos(pattern, flag)

    endwhile

    return 0 

endfunction

"""""""""""""""""""""""""""""""""""""""""""""
" vim:sts=4:sw=4:ft=vim

