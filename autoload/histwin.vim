" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: 2010, Jan 20
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.7.2
" Copyright:   (c) 2009 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" TODO: "       - write documentation
"       - don't use matchadd for syntax highlighting but use
"         appropriate syntax highlighting rules

" Init:
let s:cpo= &cpo
set cpo&vim

" Show help banner?
" per default enabled, you can change it,
" if you set g:undobrowse_help to 0 e.g.
" put in your .vimrc
" :let g:undo_tree_help=0
let s:undo_help=(exists("g:undo_tree_help") ? g:undo_tree_help : 
			\(exists("s:undo_help") ? s:undo_help : 1) )"}}}

" Functions:
fun! s:Init()
	if !exists("s:undo_winname")
		let s:undo_winname='Undo_Tree'
	endif
	if !exists("b:undo_tagdict")
		let b:undo_tagdict={}
	endif
	if !exists("b:undo_list")
	    let b:undo_list=[]
	endif
	let s:undo_tree_wdth=(exists('g:undo_tree_wdth') ? g:undo_tree_wdth : 30)
	if bufname('') != s:undo_winname
		"exe bufwinnr(s:orig_buffer) . 'wincmd w'
		let s:orig_buffer = bufnr('')
	endif
	"let s:orig_buffer = bufname('')
endfun 

fun! s:ReturnHistList(winnr)
    exe a:winnr . ' wincmd w'
	let histlist=[]
	redir => a
	sil :undol
	redir end
	" First item contains the header
	let templist=split(a, '\n')[1:]
	" include the starting point as the first change.
	" unfortunately, there does not seem to exist an 
	" easy way to obtain the state of the first change,
	" so we will be inserting a dummy entry and need to
	" check later, if this is called.
	call add(histlist, {'change': 0, 'number': 0, 'time': '00:00:00'})
	if empty(get(b:undo_tagdict, 0, ''))
		let b:undo_tagdict[0]='Start Editing'
	endif
	for item in templist
		let change	=  matchstr(item, '^\s\+\zs\d\+') + 0
		"let change  =  changenr()
		let nr		=  matchstr(item, '^\s\+\d\+\s\+\zs\d\+') + 0
		let time	=  matchstr(item, '^\%(\s\+\d\+\)\{2}\s\+\zs.*$')
	if time !~ '\d\d:\d\d:\d\d'
	   let time=matchstr(time, '^\d\+')
	   let time=strftime('%H:%M:%S', localtime()-time)
	endif
	   call add(histlist, {'change': change, 'number': nr, 'time': time})
	endfor
	return histlist
endfun 

fun! s:HistWin()
	let undo_buf=bufwinnr('^'.s:undo_winname.'$')
	if undo_buf != -1
		exe undo_buf . 'wincmd w'
		if winwidth(0) != s:undo_tree_wdth
			exe "vert res " . s:undo_tree_wdth
		endif
	else
	execute s:undo_tree_wdth . "vsp " . s:undo_winname
	setl noswapfile buftype=nowrite bufhidden=delete foldcolumn=0 nobuflisted nospell
	let undo_buf=bufwinnr("")
	endif
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	return undo_buf
endfun 

fun! s:PrintUndoTree(winnr)
	let bufname  = (empty(bufname(s:orig_buffer)) ? '[No Name]' : fnamemodify(bufname(s:orig_buffer),':t'))
	let changenr = changenr()
	exe a:winnr . 'wincmd w'
	let save_cursor=getpos('.')
	setl modifiable
	" silent because :%d outputs this message:
	" --No lines in buffer--
	silent %d _
	let histlist = getbufvar(s:orig_buffer, 'undo_list')
	let tagdict  = getbufvar(s:orig_buffer, 'undo_tagdict')
	call setline(1,'Undo-Tree: '.bufname)
	put =repeat('=', strlen(getline(1)))
	put =''
	call s:PrintHelp(s:undo_help)
	call append('$', printf("%s %-9s %s", "Nr", "  Time", "Tag"))
	let i=1
	for line in histlist
		let tag = get(tagdict, i-1, '')
		let tag = (empty(tag) ? tag : '/'.tag.'/')
		call append('$', 
		\ printf("%0*d) %8s %s", 
		\ strlen(len(histlist)), i, line['time'], 
		\ tag ))
		let i+=1
	endfor
	call s:MapKeys()
	call s:HilightLines(s:GetCurrentState(changenr,histlist)+1)
	setl nomodifiable
	let ret=setpos('.', save_cursor)
endfun 

fun! s:HilightLines(changenr)
	" check for availability of matchadd()/clearmatches()
	if !exists("*matchadd") || !exists("*clearmatches")
		return
	endif
	" only highlight, if those groups are declared.
    call clearmatches()
	if hlexists('Title')		|	call matchadd('Title', '^\%1lUndo-Tree: \zs.*$')	|	endif
	if hlexists("Comment")		| 	call matchadd('Comment', '^".*$')					|	endif
	if hlexists("Identifier")	| 	call matchadd('Identifier', '^\d\+\ze)')			|	endif
	if hlexists("Special")		| 	call matchadd('Special', '/\zs.*\ze/$')				|	endif
	if hlexists("Ignore")		| 	call matchadd('Ignore', '/$')						|	endif
	if hlexists("Ignore")		| 	call matchadd('Ignore', '/\ze.*/$')					|	endif
	if hlexists("Underlined")	| 	call matchadd('Underlined', '^\d\+)\s\+\zs\S\+')	|	endif
	if a:changenr 
		if hlexists("PmenuSel") | 	call matchadd('PmenuSel', '^0*'.a:changenr.')[^/]*')| endif
	endif
endfun 

fun! s:PrintHelp(...)
	if a:1
		put =\"\\" I\t  Toggle this help\"
		put =\"\\" <Enter> goto undo branch\"
		put =\"\\" <C-L>\t  Update view\"
		put =\"\\" T\t  Tag sel. branch\"
		put =\"\\" D\t  Diff sel. branch\"
		put =\"\\" R\t  Replay sel. branch\"
		put =\"\\" Q\t  Quit window\"
	else
		put =\"\\" I\t Toggle help screen\"
	endif
	put =''
endfun 

fun! s:DiffUndoBranch(change)
	let prevchangenr=<sid>UndoBranch(a:change)
	let buffer=getline(1,'$')
	exe ':u ' . prevchangenr
	let tempname=tempname()
	exe ':vsp '.tempname
	call setline(1, s:orig_buffer . ' branch ' . a:change)
	call append('$',buffer)
	silent w!
	diffthis
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	diffthis
endfun 

fun! s:GetCurrentState(changenr,histlist)
	let i=0
	for item in a:histlist
	    if item['change'] == a:changenr
		   return i
		endif
		let i+=1
	endfor
	return -1
endfun!

fun! s:ReplayUndoBranch(change)
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	let end=b:undo_list[a:change-1]['number']
	exe ':u ' . b:undo_list[a:change-1]['change']
	exe 'normal ' . end . 'u' 
	redraw
	let start=1
	while start <= end
	red
	redraw
	sleep 100m
	let start+=1
	endw
endfun 

fun! s:ReturnBranch()
	return matchstr(getline('.'), '^\d\+\ze')+0
endfun 

fun! s:ToggleHelpScreen()
	let s:undo_help=!s:undo_help
	exe bufwinnr(s:orig_buffer) . ' wincmd w'
	call s:PrintUndoTree(s:HistWin())
endfun 

fun! s:UndoBranchTag(change)
	let tagdict=getbufvar(s:orig_buffer, 'undo_tagdict')
	call inputsave()
	let tag=input("Tagname " . a:change . ": ", get(tagdict, a:change-1, ''))
	call inputrestore()
	let tagdict[a:change-1] = tag
	call setbufvar('#', 'undo_tagdict', tagdict)
	call s:PrintUndoTree(s:HistWin())
endfun 

fun! s:UndoBranch(change)
	exe bufwinnr(s:orig_buffer) . 'wincmd w'
	let cmd=''
	let cur_changenr=changenr()
	if a:change <= len(b:undo_list)
		if a:change<=1
		   " Jump back to initial state
			let cmd=':earlier 9999999'
		else
			let cmd=':u '.b:undo_list[a:change-1]['change']
		endif
			exe cmd
	endif
	return cur_changenr
endfun 

fun! s:MapKeys()
	"noremap <script> <buffer> <expr> <CR> s:UndoBranch(s:ReturnBranch())
	noremap <script> <buffer> I     :<C-U>silent                                      :call <sid>ToggleHelpScreen()<CR>
	noremap <script> <buffer> <CR>  :<C-U>silent                                      :call <sid>UndoBranch(<sid>ReturnBranch())<CR>:call histwin#UndoBrowse()<CR>
	noremap <script> <buffer> T     :call <sid>UndoBranchTag(<sid>ReturnBranch())<CR>
	noremap <script> <buffer> D     :<C-U>silent                                      :call <sid>DiffUndoBranch(<sid>ReturnBranch())<CR>
	noremap <script> <buffer> <C-L> :<C-U>silent                                      :call histwin#UndoBrowse()<CR>
	noremap <script> <buffer> R     :<C-U>silent                                      :call <sid>ReplayUndoBranch(<sid>ReturnBranch())<CR>
	noremap <script> <buffer> Q     :<C-U>q<CR>
endfun 

fun! histwin#UndoBrowse()
	if &ul != -1
		call s:Init()
		let b:undo_win  = s:HistWin()
		let b:undo_list = s:ReturnHistList(bufwinnr(s:orig_buffer))
		call s:PrintUndoTree(b:undo_win)
	else
		echoerr "Undo has been disabled. Check your undolevel setting!"
	endif
endfun 

" Restore:
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" spell spelllang=en fdm=syntax
