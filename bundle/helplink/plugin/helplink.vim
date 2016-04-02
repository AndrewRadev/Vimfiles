" helplink.vim: link to Vim help pages with ease.
"
" http://code.arp242.net/helplink.vim
"
" See the bottom of this file for copyright & license information.


"##########################################################
" Initialize some stuff
scriptencoding utf-8
"if exists('g:loaded_helplink') | finish | endif
let g:loaded_helplink = 1
let s:save_cpo = &cpo
set cpo&vim

let g:helplink_formats = {
\	'markdown':  "'[`:help ' . l:tagname . '`](' . l:url . ')'",
\	'html': "'<a href=\"' . l:url . '\"><code>:help ' . l:tagname . '</code></a>'",
\	'bbcode': "'[url=' . l:url . '][code]:help ' . l:tagname . '[/code][/url]'"
\}


"##########################################################
" Options
let g:helplink_copy_to_registers = ['+', '*']
let g:helplink_url = 'http://vimhelp.appspot.com/%%FILE%%.html#%%TAGNAME_QUOTED%%'
let g:helplink_default_format = 'markdown'


"##########################################################
" Commands
command! -nargs=* Helplink call s:echo(helplink#link(<q-args>))


"##########################################################
" Functions
fun! helplink#link(...) abort
	let l:format = (a:0 >= 1 && !empty(a:1)) ? a:1 : g:helplink_default_format
	if !has_key(g:helplink_formats, l:format)
		echoerr "Unknown format: `" . l:format . "'"
		return
	endif

	let l:r = s:make_url()
	if empty(l:r) | return | endif

	let [l:tagname, l:tagname_q, l:url] = l:r
	let l:out = eval(g:helplink_formats[l:format])
	call s:copy_to_registers(l:out)
	return l:out
endfun

"##########################################################
" Helper functions

" Echo only if string is non-empty
fun! s:echo(str)
	if !empty(a:str) | echo a:str | endif
endfun


" Get the name of the nearest tag. If there are multiple ask the user to choose
" one.
fun! s:get_tag() abort
	let l:save_cursor = getpos('.')

	" Search backwards for the first tag
	normal! $
	if !search('\*\zs[^*]\+\*$', 'bcW')
		call setpos('.', l:save_cursor)
		echohl ErrorMsg | echom 'No tag found before the cursor.' | echohl None
		return
	endif

	" There are often a bunch of tags on a single line, get them all
	let l:tags = map(split(matchlist(getline('.'), '\*.*\*')[0]), 'v:val[1:-2]')

	" Just one tag, return it
	if len(l:tags) == 1
		call setpos('.', l:save_cursor)
		return l:tags[0]
	endif

	" Let the user choose
	let l:i = 1
	for l:t in l:tags
		echo l:i . ' ' . l:t
		let l:i += 1
	endfor
	let l:choice = input('Which one: ')
	echo "\n"
	call setpos('.', l:save_cursor)
	return l:tags[l:choice - 1]
endfun


" Escape HTML
fun! s:quote_url(str) abort
	let l:new = ''
	for l:i in range(1, strlen(a:str))
		let l:c = a:str[l:i - 1]
		if l:c =~ '\w'
			let l:new .= l:c
		else
			let l:new .= printf('%%%02x', char2nr(l:c))
		endif
	endfor
	return l:new
endfun


" Make an URL
fun! s:make_url() abort
	if expand('%') == ''
		echohl ErrorMsg | echom 'This buffer has no file.' | echohl None
		return
	endif

	let l:file = split(expand('%'), '/')[-1]
	let l:tagname = s:get_tag()
	if empty(l:tagname) | return | endif
	let l:tagname_q = s:quote_url(l:tagname)

	let l:url = g:helplink_url
	let l:url = substitute(l:url, '%%FILE%%', l:file, 'g')
	let l:url = substitute(l:url, '%%TAGNAME%%', l:tagname, 'g')
	let l:url = substitute(l:url, '%%TAGNAME_QUOTED%%', l:tagname_q, 'g')

	return [l:tagname, l:tagname_q, l:url]
endfun


" Copy {str} to all the registers in |g:helplink_copy_to_registers|
fun! s:copy_to_registers(str) abort
	if !empty(g:helplink_copy_to_registers)
		for l:reg in g:helplink_copy_to_registers
			call setreg(l:reg, a:str)
		endfor
	endif
endfun


let &cpo = s:save_cpo
unlet s:save_cpo


" The MIT License (MIT)
"
" Copyright © 2015-2016 Martin Tournoij
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising
" from, out of or in connection with the software or the use or other dealings
" in the software.
