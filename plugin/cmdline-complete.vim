" Script Name: cmdline-complete.vim
" Version:     1.1.3
" Last Change: July 18, 2008
" Author:      Yuheng Xie <xie_yuheng@yahoo.com.cn>
"
" Description: complete command-line (: / etc.) from the current file
"
" Usage:       When editing the command-line, press <c-p> or <c-n> to complete
"              the word before the cursor, using keywords in the current file.
"
" Install:     Just drop this script file into vim's plugin directory.
"
"              If you want to use other keys instead of default <c-p> <c-n> to
"              trigger the completion, please say in your .vimrc
"                  cmap <c-y> <Plug>CmdlineCompleteBackward
"                  cmap <c-e> <Plug>CmdlineCompleteForward
"              this will use Ctrl-Y Ctrl-E for search backward and forward.
"
"              Without python, speed will be a bit slow with large file (e.g.
"              > 100K). Compile your vim with python is recommended.

" Anti reinclusion guards
if exists('g:loaded_cmdline_complete') && !exists('g:force_reload_cmdline_complete')
	finish
endif

" Support for |line-continuation|
let s:save_cpo = &cpo
set cpo&vim

" Default bindings

if !hasmapto('<Plug>CmdlineCompleteBackward', 'c')
	cmap <unique> <silent> <c-p> <Plug>CmdlineCompleteBackward
endif
if !hasmapto('<Plug>CmdlineCompleteForward', 'c')
	cmap <unique> <silent> <c-n> <Plug>CmdlineCompleteForward
endif

cnoremap <silent> <Plug>CmdlineCompleteBackward <c-r>=<sid>CmdlineComplete(1)<cr>
cnoremap <silent> <Plug>CmdlineCompleteForward  <c-r>=<sid>CmdlineComplete(0)<cr>

" Functions

" define variables if they don't exist
function! s:InitVariables()
	if !exists("s:seed")
		let s:seed = ""
		let s:completions = [""]
		let s:completions_set = {}
		let s:comp_i = 0
		let s:search_cursor = getpos(".")
		let s:sought_bw = 0
		let s:sought_fw = 0
		let s:last_cmdline = ""
		let s:last_pos = 0
	endif
endfunction

" generate completion list in python
function! s:GenerateCompletionsPython(seed, backward)
	let success = 0

python << EOF
try:
	import sys, re, vim

	seed = vim.eval("a:seed")
	backward = int(vim.eval("a:backward"))

	def chars2range(list):
		range_text = ""
		for i in range(len(list)):
			if i > 0 and list[i - 1] == list[i] - 1 \
					and i < len(list) - 1 and list[i + 1] == list[i] + 1:
				if range_text[-1] != "-":
					range_text += "-"
			else:
				range_text += '\\x%02X' % list[i]
		return "[" + range_text + "]"

	# simulate vim's \k
	k = chars2range(map(lambda x: int(x), vim.eval( \
			"filter(range(256), 'nr2char(v:val) =~ \"\\\\k\"')")))

	regexp = re.compile(r'(?<!' + k + r')' + re.escape(seed) + k + r'+')
	if not seed:
		regexp = re.compile(r'(?<!' + k + r')' + k + k + r'+')
	elif int(vim.eval("&ignorecase")) \
			and not (int(vim.eval("&smartcase")) and re.search(r'[A-Z]', seed)):
		regexp = re.compile(r'(?i)(?<!' + k + r')' + re.escape(seed) + k + r'+')

	buffer = vim.current.buffer
	completions_set = vim.eval("s:completions_set")
	search_cursor = map(lambda x: int(x), vim.eval("s:search_cursor"))
	sought_bw = int(vim.eval("s:sought_bw"))
	sought_fw = int(vim.eval("s:sought_fw"))

	r = []
	if sought_bw < search_cursor[1]:
		r1 = search_cursor[1] - sought_bw
		r2 = 1
		if sought_fw > len(buffer) - search_cursor[1] + 1:
			r2 = sought_fw - len(buffer) + search_cursor[1]
		if backward:
			r = [r1, r2]
		else:
			r = [r2, r1]
	if sought_fw < len(buffer) - search_cursor[1] + 1:
		r1 = len(buffer)
		r2 = search_cursor[1] + sought_fw
		if sought_bw > search_cursor[1]:
			r1 = len(buffer) - sought_bw + search_cursor[1]
		if backward:
			r = r + [r1, r2]
		else:
			r = [r2, r1] + r

	while r:
		candidates = regexp.findall(buffer[r[0] - 1])
		if r[0] == search_cursor[1]:
			candidates = []
			m = regexp.search(buffer[r[0] - 1])
			while m:
				if backward and (not sought_bw and m.start() < search_cursor[2] \
						or sought_bw and m.start() >= search_cursor[2]) \
						or not backward and (sought_fw and m.end() < search_cursor[2] \
						or not sought_fw and m.end() >= search_cursor[2]):
					candidates.append(m.group())
				m = regexp.search(buffer[r[0] - 1], m.end())

		found = False

		if candidates:
			if backward:
				for candidate in reversed(candidates):
					if candidate not in completions_set:
						completions_set[candidate] = 1
						vim.command("let s:completions_set['" + candidate + "'] = 1")
						vim.command("call insert(s:completions, '" + candidate + "')")
						vim.command("let s:comp_i = s:comp_i + 1")
						found = True
			else:
				for candidate in candidates:
					if candidate not in completions_set:
						completions_set[candidate] = 1
						vim.command("let s:completions_set['" + candidate + "'] = 1")
						vim.command("call add(s:completions, '" + candidate + "')")
						found = True

		if backward:
			vim.command("let s:sought_bw += 1")
		else:
			vim.command("let s:sought_fw += 1")

		if found: break

		if   r[1] > r[0]: r[0] += 1
		elif r[1] < r[0]: r[0] -= 1
		else: del r[:2]

	vim.command("let success = 1")

except ImportError: pass
EOF

	return success
endfunction

" generate completion list
function! s:GenerateCompletions(seed, backward)
	let regexp = '\<' . a:seed . '\k\+'
	if empty(a:seed)
		let regexp = '\<\k\k\+'
	elseif a:seed =~ '\K'
		let regexp = '\<\(\V' . a:seed . '\)\k\+'
	endif
	if &ignorecase && !(&smartcase && a:seed =~ '\C[A-Z]')
		let regexp = '\c' . regexp
	endif

	" backup 'ignorecase', do searching with 'noignorecase'
	let save_ignorecase = &ignorecase
	set noignorecase

	let r = []
	if s:sought_bw < s:search_cursor[1]
		let r1 = s:search_cursor[1] - s:sought_bw
		let r2 = 1
		if s:sought_fw > line("$") - s:search_cursor[1] + 1
			let r2 = s:sought_fw - line("$") + s:search_cursor[1]
		endif
		if a:backward
			let r = [r1, r2]
		else
			let r = [r2, r1]
		endif
	endif
	if s:sought_fw < line("$") - s:search_cursor[1] + 1
		let r1 = line("$")
		let r2 = s:search_cursor[1] + s:sought_fw
		if s:sought_bw > s:search_cursor[1]
			let r1 = line("$") - s:sought_bw + s:search_cursor[1]
		endif
		if a:backward
			let r = r + [r1, r2]
		else
			let r = [r2, r1] + r
		endif
	endif

	while len(r)
		let candidates = []

		let line = getline(r[0])
		let start = match(line, regexp)
		while start != -1
			let candidate = matchstr(line, '\k\+', start)
			let next = start + len(candidate)
			if r[0] != s:search_cursor[1]
					\ || a:backward && (!s:sought_bw && start < s:search_cursor[2]
						\ || s:sought_bw && start >= s:search_cursor[2])
					\ || !a:backward && (s:sought_fw && next < s:search_cursor[2]
						\ || !s:sought_fw && next >= s:search_cursor[2])
				call add(candidates, candidate)
			endif
			let start = match(line, regexp, next)
		endwhile

		let found = 0

		if !empty(candidates)
			if a:backward
				let i = len(candidates) - 1
				while i >= 0
					if !has_key(s:completions_set, candidates[i])
						let s:completions_set[candidates[i]] = 1
						call insert(s:completions, candidates[i])
						let s:comp_i = s:comp_i + 1
						let found = 1
					endif
					let i = i - 1
				endwhile
			else
				let i = 0
				while i < len(candidates)
					if !has_key(s:completions_set, candidates[i])
						let s:completions_set[candidates[i]] = 1
						call add(s:completions, candidates[i])
						let found = 1
					endif
					let i = i + 1
				endwhile
			endif
		endif

		if a:backward
			let s:sought_bw += 1
		else
			let s:sought_fw += 1
		endif

		if found
			break
		endif

		if r[1] > r[0]
			let r[0] += 1
		elseif r[1] < r[0]
			let r[0] -= 1
		else
			call remove(r, 0, 1)
		endif
	endwhile

	" restore 'ignorecase'
	let &ignorecase = save_ignorecase

	return 1
endfunction

" return next completion, to be used in c_CTRL-R =
function! s:CmdlineComplete(backward)
	" define variables if they don't exist
	call s:InitVariables()

	let cmdline = getcmdline()
	let pos = getcmdpos()

	" if cmdline, cmdpos or cursor changed since last call,
	" re-generate the completion list
	if cmdline != s:last_cmdline || pos != s:last_pos
		let s:last_cmdline = cmdline
		let s:last_pos = pos

		let s = match(strpart(cmdline, 0, pos - 1), '\k*$')
		let s:seed = strpart(cmdline, s, pos - 1 - s)
		let s:completions = [s:seed]
		let s:completions_set = {}
		let s:comp_i = 0
		let s:search_cursor = getpos(".")
		let s:sought_bw = 0
		let s:sought_fw = 0
	endif

	if s:sought_bw + s:sought_fw <= line("$") && (
			\  a:backward && s:comp_i == 0 ||
			\ !a:backward && s:comp_i == len(s:completions) - 1)
		let success = 0
		if has('python')
			let success = s:GenerateCompletionsPython(s:seed, a:backward)
		endif
		if !success
			let success = s:GenerateCompletions(s:seed, a:backward)
		endif
	endif

	let old = s:completions[s:comp_i]

	if a:backward
		if s:comp_i == 0
			let s:comp_i = len(s:completions) - 1
		else
			let s:comp_i = s:comp_i - 1
		endif
	else
		if s:comp_i == len(s:completions) - 1
			let s:comp_i = 0
		else
			let s:comp_i = s:comp_i + 1
		endif
	endif

	let new = s:completions[s:comp_i]

	" remember the last cmdline, cmdpos and cursor for next call
	let s:last_cmdline = strpart(s:last_cmdline, 0, s:last_pos - 1 - strlen(old))
			\ . new . strpart(s:last_cmdline, s:last_pos - 1)
	let s:last_pos = s:last_pos - len(old) + len(new)

	" feed some keys to overcome map-<silent>
	call feedkeys(" \<bs>")

	return substitute(old, ".", "\<c-h>", "g") . new
endfunction
