" Highlights QuickFix errors
" Last Change:	2009 Nov 04
" Maintainer:	Mikael Eriksson <mikael_eriksson@miffe.org>
" License:      CC-BY-SA-3

if exists("g:loaded_QuickFixHighlight")
	finish
endif
let g:loaded_QuickFixHighlight = 1

function QuickFixHighlightClear()
	let m = getmatches()
	for i in m
		if i.group == "QuickFixError"
			call matchdelete(i.id)
		endif
	endfor
endfunction

function QuickFixHighlight()
	call QuickFixHighlightClear()

	let qflist = getqflist()
	for i in qflist
		if i.lnum > 0 && bufnr("%") == i.bufnr
			call matchadd('QuickFixError', '\%' . i.lnum . 'l', -1)
		endif
	endfor
endfunction

au QuickFixCmdPost * call QuickFixHighlight()
au BufEnter * call QuickFixHighlight()
hi link QuickFixError ErrorMsg
command -nargs=0 QFhi call QuickFixHighlight()
command -nargs=0 QFhic call QuickFixHighlightClear()
