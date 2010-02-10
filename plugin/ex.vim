" Description: Emacs-like efficiency in ex-mode.
"
" Often I need to make edits when I'm on the command line
" (ex mode). To speed up the process I created a handful of
" functions that I've found myself wishing I had at my disposal on the command
" line.
"
" I didn't want (or even know if it's possible) to create a normal-command
" mode in Vim. I thought Emacs-style mappings would be most convenient here.
" You can feel free to map each function however you see fit though.
"
" Author: Joel Jackson (boboat3000@hotmail.com)
" Version: 1.0
" Last Modified: Wed Dec 30 20:12:56 CST 2009

" It might work for versions less than this, but I haven't tried it.
if v:version < 700
	finish
endif

" MAPPINGS
" Feel free to change these. Where possible I've tried to mimic the Emacs
" key-bindings...
cnoremap  <Home>
cnoremap  <End>
cnoremap  <Left>
cnoremap  <Right>
cnoremap  <C-\>eCopyText()<cr>
cnoremap  <C-\>eBackwardsPositionCursor()<cr>
cnoremap  <C-\>eKillLine()<cr>
cnoremap  
cnoremap  <S-Left>
cnoremap  <S-Right>
cnoremap  <C-\>eReverse_Search_History()<cr>
cnoremap  <Home>BufferMessage


function! CopyText()
	let @@ = getcmdline()
  if &clipboard =~ 'unnamed'
    let @* = @@
    let @+ = @@
  endif
	return getcmdline()
endfunction
" --------------------------------------------------------------------------------


" Mimic the T command behavior of Vim in normal mode...
function! BackwardsPositionCursor()
	let l:cmdline = getcmdline()
	let l:subcmd = strpart(l:cmdline, 0, getcmdpos())
	echo l:subcmd
	let l:findchar = nr2char(getchar())
	call setcmdpos(len(matchstr(l:subcmd, "^.*" . l:findchar)) + 1)
	return l:cmdline
endfunction
" --------------------------------------------------------------------------------


function! KillLine()
	let @@ = getcmdline()
  if &clipboard =~ 'unnamed'
    let @* = @@
    let @+ = @@
  endif
	return ""
endfunction
" --------------------------------------------------------------------------------


function! Reverse_Search_History()
	let l:cmdline = getcmdline()
	let l:history_items = Get_History()
	let l:match_number = 1
	let l:next_match = Next_History_Match(l:history_items, l:cmdline, l:match_number)
	echo Search_Prompt(l:next_match)

	" Wait around and see what the user wants to do...
	while 1
		let l:findchar = nr2char(getchar())
		if l:findchar == '' " find next reverse match...
			let l:match_number += 1
			let l:next_match = Next_History_Match(l:history_items, l:cmdline, l:match_number)
			echo Search_Prompt(l:next_match)
		elseif l:findchar == '' " find next forward match...
			let l:match_number -= 1
			let l:next_match = Next_History_Match(l:history_items, l:cmdline, l:match_number)
			echo Search_Prompt(l:next_match)
		elseif l:findchar == '' " Delete a word or word boundary...
			let l:next_match = Delete_Word(l:next_match)
			return l:next_match
		elseif l:findchar == '' " Delete a character...
			let l:next_match = Remove_Last_Byte(l:next_match)
			return l:next_match
		elseif l:findchar =~ '\p' " Print typed the character...
			let l:cmdline .= l:findchar
			let l:next_match = l:cmdline
			echo Search_Prompt(l:next_match)
		else											" accept suggestion...
			return l:next_match
		endif
	endwhile
endfunction
" --------------------------------------------------------------------------------


function! Delete_Word(text)
	if Last_Character(a:text) =~ Word_Boundary()
		return Remove_Last_Byte(a:text)
	else
		return Remove_Last_Word(a:text)
	endif
endfunction
" --------------------------------------------------------------------------------


function! Remove_Last_Word(text)
	return matchstr(a:text, "^.*" . Word_Boundary())
endfunction
" --------------------------------------------------------------------------------


function! Remove_Last_Byte(text)
	return strpart(a:text, 0, len(a:text) - 1)
endfunction
" --------------------------------------------------------------------------------


" I know this is not a complete list of the word boundaries, but its' a start...
function! Word_Boundary()
	return "[ /\"\_]"
endfunction
" --------------------------------------------------------------------------------


function! Search_Prompt(msg)
	return "(iSearch)> " . a:msg
endfunction
" --------------------------------------------------------------------------------


function! Last_Character(text)
	return strpart(a:text, len(a:text) - 1, 1)
endfunction
" --------------------------------------------------------------------------------


function! Next_History_Match(history_buffer, expr, count)
	if a:count < 1 || count > len(a:history_buffer)
		return ""
	endif

	let l:count = 0
	for index in range(0, len(a:history_buffer) - 1)
		if match(a:history_buffer[index], a:expr) > -1
			let l:count += 1
			if l:count == a:count
				return a:history_buffer[index]
			endif
		endif
	endfor
	return a:expr
endfunction
" --------------------------------------------------------------------------------


" I couldn't seem to find an in-built function that returned more than a
" single line from the command history...
function! Get_History()
	let l:history_buffer = []
	for historyitem in range(histnr("cmd"), 1, -1)
		let l:next_item = histget("cmd", historyitem)
		if l:next_item != ''
			let l:history_buffer += [l:next_item]
		endif
	endfor
	return l:history_buffer
endfunction
" --------------------------------------------------------------------------------


" The inbuilt vim :source function doesn't seem to accept a range, so I've
" added the capabilities here...
function! Source()
	execute getline(".")
endfunction
" --------------------------------------------------------------------------------


" Put ex output into a buffer instead of a disappearing, uneditable display...
" This function is a modified version of the Vim Tips Wiki - Tip 95
function! BufferMessage(cmd)
  redir => message
  silent execute a:cmd
  redir END
  edit *Messages*
  silent put=message
  set nomodified
endfunction
command! -nargs=+ -complete=command BufferMessage call BufferMessage(<q-args>)
" --------------------------------------------------------------------------------
