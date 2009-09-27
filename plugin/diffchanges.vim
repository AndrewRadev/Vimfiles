" Filename:      diffchanges.vim
" Description:   Shows the changes made to the current buffer in a diff format
" Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
" Last Modified: Mon 2008-03-10 02:07:20 (-0400)

if v:version < 700
	finish
endif

if exists("loaded_diffchanges")
	finish
endif

let loaded_diffchanges = 1

let g:diffchanges_diff = []
let g:diffchanges_patch = []
let s:diffchanges_modes = ['diff', 'patch']

if !exists('g:diffchanges_patch_cmd')
	let g:diffchanges_patch_cmd = 'diff -u'
endif

let s:save_cpo = &cpo
set cpo&vim

" Mappings {{{
if !hasmapto('<Plug>DiffChangesDiffToggle')
	nmap <silent> <unique> <leader>dcd <Plug>DiffChangesDiffToggle
endif

if !hasmapto('<Plug>DiffChangesPatchToggle')
	nmap <silent> <unique> <leader>dcp <Plug>DiffChangesPatchToggle
endif

nnoremap <unique> <script> <Plug>DiffChangesDiffToggle  <SID>DiffChangesDiffToggle
nnoremap <unique> <script> <Plug>DiffChangesPatchToggle <SID>DiffChangesPatchToggle

nnoremap <SID>DiffChangesDiffToggle  :DiffChangesDiffToggle<cr>
nnoremap <SID>DiffChangesPatchToggle :DiffChangesPatchToggle<cr>

command! -bar DiffChangesDiffToggle  :call s:DiffChangesToggle('diff')
command! -bar DiffChangesPatchToggle :call s:DiffChangesToggle('patch')

nnoremenu <script> &Plugin.&DiffChanges.&Diff\ Toggle  <SID>DiffChangesDiffToggle
nnoremenu <script> &Plugin.&DiffChanges.&Patch\ Toggle <SID>DiffChangesPatchToggle
"}}}

function! s:DiffChangesToggle(mode) "{{{1
	if count(s:diffchanges_modes, a:mode) == 0
		call s:Warn("Invalid mode '".a:mode."'")
		return
	endif
	if len(expand('%')) == 0
		call s:Warn("Unable to show changes for unsaved buffer")
		return
	endif
	let [dcm, pair] = s:DiffChangesPair(bufnr('%'))
	if count(s:diffchanges_modes, dcm) == 0
		call s:DiffChangesOn(a:mode)
	else
		call s:DiffChangesOff()
	endif
endfunction

function! s:DiffChangesOn(mode) "{{{1
	if count(s:diffchanges_modes, a:mode) == 0
		return
	endif
	let filename = expand('%')
	let diffname = tempname()
	let buforig = bufnr('%')
	execute 'silent w! '.diffname
	let diff = system(g:diffchanges_patch_cmd.' '.filename.' '.diffname)
	call delete(diffname)
	if len(diff) == 0
		call s:Warn('No changes found')
		return
	endif
	if a:mode == 'diff'
		call writefile(readfile(filename, 'b'), diffname, 'b')
		let b:diffchanges_savefdm = &fdm
		let b:diffchanges_savefdl = &fdl
		let save_ft=&ft
		diffthis
		vert new
		let &ft=save_ft
		execute '%read '.filename
		diffthis
	elseif a:mode == 'patch'
		below new
		setlocal filetype=diff
		setlocal foldmethod=manual
		silent 0put=diff
		1
	endif
	set buftype=nofile
	let bufname = "Changes made to '".filename."'"
	silent file `=bufname`
	autocmd BufUnload <buffer> call s:DiffChangesOff()
	let bufdiff = bufnr('%')
	call add(g:diffchanges_{a:mode}, [buforig, bufdiff])
endfunction

function! s:DiffChangesOff() "{{{1
	let [dcm, pair] = s:DiffChangesPair(bufnr('%'))
	execute 'autocmd! BufUnload <buffer='.pair[1].'>'
	execute 'bdelete! '.pair[1]
	execute bufwinnr(pair[0]).'wincmd w'
	if dcm == 'diff'
		diffoff
		let &fdm = b:diffchanges_savefdm
		let &fdl = b:diffchanges_savefdl
	endif
	let dcp = g:diffchanges_{dcm}
	call remove(dcp, index(dcp, pair))
endfunction

function! s:DiffChangesPair(buf_num) "{{{1
	for dcm in s:diffchanges_modes
		let pairs = g:diffchanges_{dcm}
		for pair in pairs
			if count(pair, a:buf_num) > 0
				return [dcm, pair]
			endif
		endfor
	endfor
	return [0, 0]
endfunction

function! s:Warn(message) "{{{1
	echohl WarningMsg | echo a:message | echohl None
endfunction

function! s:Error(message) "{{{1
	echohl ErrorMsg | echo a:message | echohl None
endfunction
"}}}

let &cpo = s:save_cpo
