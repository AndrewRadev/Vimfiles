"=============================================================================
" Name Of File: nodiff.vim
" Description:  global plugin for getting out of the diff mode
" Maintainer:   Pavol Juhas (juhas@seas.upenn.edu)
" Last Change:  Thu Feb 4, 2005
"
" Usage:        Normally, this file should reside in the plugins
"               directory and be automatically sourced.  If not, you need
"               to manually source this file using ':source nodiff.vim'.
"
"               This file defines user command :Nodiff, where
"
"                 :Nodiff   turns off the diffmode for each window
"                 :Nodiff!  turns off the diffmode for each window and buffer
"
" Version: 1.2
"=======================================================================

if exists("loaded_nodiff")
    finish
endif
let loaded_nodiff = 1

com! -bar -bang Nodiff call s:Nodiff(<q-bang>)
function! s:Nodiff(bang)
    let cwnr = winnr()
    windo if &diff | setlocal nodiff noscb fdc& | endif
    exe cwnr . "wincmd w"
    if a:bang == "!"
	let last = bufnr("$")
	let nr = 1
	while nr <= last
	    if bufexists(nr) && getbufvar(nr, '&diff')
		call setbufvar(nr, '&diff', 0)
		call setbufvar(nr, '&scb', 0)
		call setbufvar(nr, '&fdc', '&fdc')
	    endif
	    let nr = nr + 1
	endwhile
    endif
endfunction
