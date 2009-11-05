" Vim syntax file
" Language:	vorg
" Maintainer:	Ithai Levi (http://twitter.com/L3V3L9)
"
" About:	vorg is a simple file format for managing your notes, tasks
" 		and diary. 
" 
" Usage:	create a file with the .vorg extension and insert the
" 		following line:
" 		
" 		vim:ft=vorg
" 		
" 		vorg format:
"
" 		- Topic Title
" 		  - Sub Topic Title (tag)
" 		    - Sub Sub Topic Title
"		      sub sub topic text
"		      - [ ] sub sub topic task
" 		
" 		Notes: To indent topics you must use <TAB>!
"		       You can also use asterisk signs (*) instead of minus
"		       signs(-)
"		       You can create tasks without sub items by omitting the -
"
"		- Topic with a context @context
"		- Topic with a deadline < {date}
"		- Topic with a list of tags (tag1,tag2,tag3)
"		- Topic with a timestamp | {date} @ {time}
"		- Topic with a timestamp | {datetime}
"		- Topic with a text content
"		  some text...
"
"
" 		Insert-mode Shortcuts:
"
"		-- create a new indented item
"		-= create a new task
"
"		ctrl+j move line down
"		ctrl+k move line up
"
"		Normal-mode Shortcuts:
"		
"		<TAB> expand/collapse topics
"
"		ctrl+t find tags (type the tag name and then press <CR>)
"		ctrl+o find contexts (type the context and then press <CR>)
"
"		,c checkmark a task
"		,u uncheckmark a task
"
"		,w follow hyperlink
"
" 		For updates follow me on twitter and look for the upcoming
" 		vorg webcast.
"
" Installation: Just put this file in your ~/.vim/syntax folder
" 		
" 		It is recommended to install the followin plugins as well:
" 		- speeddating
" 		        
"

" Syntax Definition
syntax clear

syn match vorgContext         "[^'"]@[^ ,;\t]*[^'"]" contained
syn match vorgLink            "\%(http://\|www\.\)[^ ,;\t]*" contained
syn match vorgDeadline        "<\ \d*[/-]\d*[/-]\d*" contained
syn match vorgLogdate         "\~\ \d*[/-]\d*[/-]\d*[ ]@[ ]\d*:\d*" contained
syn match vorgTag             "(.*)" contained
syn match vorgTask            "[-\*].*\[[o\ ]\].*" contains=vorgContext,vorgTag,vorgDeadline,vorgLink
syn match vorgTask2           "\t*\[[o\ ]\].*" contains=vorgContext,vorgTag,vorgDeadline,vorgLink
syn match vorgTitle           "^[-\*].*" contains=vorgTag,vorgLink,vorgLogdate
syn match vorgTitle2           "^\t[-\*].*" contains=vorgTag,vorgLink,vorgLogdate
syn match vorgTitle3           "^\t\t\t*[-\*].*" contains=vorgTag,vorgLink,vorgLogdate
syn match vorgDone            "^\t*[-\*].*\[[X|x]\].*"
syn match vorgDone2            "^\t*\[[X|x]\].*"

hi def vorgHL                term=bold,underline cterm=bold,underline gui=underline

hi def link vorgTask2          Keyword 
hi def link vorgDone	     Comment
hi def link vorgTask          Keyword 
hi def link vorgDone2	     Comment
hi def link vorgTitle     Structure 
hi def link vorgContext       Function
hi def link vorgTitle2	     Type 
hi def link vorgTitle3	     StorageClass 
hi def link vorgTag           Special
hi def link vorgDeadline      String
hi def link vorgLogdate       String
hi def link vorgLink          vorgHL 

"Settings
set smartindent
set tabstop=2
set shiftwidth=2


" Shortcuts
ab -- <TAB>-
ab -= - [ ]
nmap ,c ma0t]rx`a
nmap ,u ma0t]r `a
nmap <F7> mz:m+<CR>==`z
nmap <F6> mz:m-2<CR>==`z

function! Browser ()
	let line = getline (".")
	let line = matchstr (line, "http://\.[^ ,;\t]*")
	exec "!firefox ".line
endfunction
map ,w :call Browser ()<CR>

" Custom Folding --------------------
function! SimpleFoldText() 
	return	repeat(' ',indent(v:foldstart)).substitute(getline(v:foldstart),"[ \t]*[-\*]","+","").' '
endfunction 
set foldtext=SimpleFoldText() " Custom fold text function

function! LimitFoldLevel(level)
	return a:level
	"if a:level>3
	"	return 3
	"else
	"	return a:level
	"endif
endfunction

function! VorgFoldExpr(lnum)
    if match(getline(a:lnum),'^[ \t]*$') != -1
	if indent(prevnonblank(a:lnum-1)) > indent(nextnonblank(a:lnum+1))
		if nextnonblank(a:lnum+1) == a:lnum+1
			return  '<'.LimitFoldLevel(indent(prevnonblank(a:lnum-1)) / &sw) 
		endif
	endif
	return '='
    endif
    if indent( nextnonblank(a:lnum+1) ) > indent( a:lnum )
	    if indent(prevnonblank(a:lnum-1)) > indent(a:lnum)
		    return '>'.(LimitFoldLevel(indent(a:lnum) / &sw  +1))
	    else
		    return LimitFoldLevel(indent( a:lnum ) / &sw  +1)
            endif
    endif


    if indent( nextnonblank(a:lnum+1) ) == indent( a:lnum )	    
	    return LimitFoldLevel(indent( a:lnum ) / &sw) 


    endif


    if indent( nextnonblank(a:lnum+1) ) < indent( a:lnum )
	    if nextnonblank(a:lnum+1) > a:lnum+1
		    return  LimitFoldLevel(indent(a:lnum) / &sw) 
	    else
		    return  '<'.LimitFoldLevel(indent(a:lnum) / &sw) 
	    endif
    endif

    return '='
endfunction

set foldmethod=expr
set foldexpr=VorgFoldExpr(v:lnum) 
nmap <TAB> za
nmap <S-TAB> zA

if exists("*SpeedDatingFormat")
	" Speeddating integration - config date format
	SpeedDatingFormat %Y-%m-%d
endif
" Quickly insert dates in insert mode
ab dd <C-R>=strftime("%Y-%m-%d")<CR>
ab dt <C-R>=strftime("%Y-%m-%d @ %H:%M")<CR>

" Shift lines up and down
nnoremap <C-j> mz:m+<CR>`z
nnoremap <C-k> mz:m-2<CR>`z
inoremap <C-j> <Esc>:m+<CR>gi
inoremap <C-k> <Esc>:m-2<CR>gi
vnoremap <C-j> :m'>+<CR>gv=`<my`>mzgv`yo`z
vnoremap <C-k> :m'<-2<CR>gv=`>my`<mzgv`yo`z

nnoremap <C-o> :/[-\*]\ *\[\ \].*@
nnoremap <C-t> :/-.*(.*.*)<LEFT><LEFT><LEFT>

hi Folded cterm=bold

"" Tip 1557 by Niels AdB
" Gather search hits, and display in a new scratch buffer.
if exists("*Gather")==0
	function! Gather(pattern)
		if !empty(a:pattern)
			let save_cursor = getpos(".")
			let orig_ft = &ft
			" append search hits to results list
			let results = []
			execute "g/" . a:pattern . "/call add(results, getline('.'))"
			call setpos('.', save_cursor)
			if !empty(results)
				" put list in new scratch buffer
				new
				setlocal buftype=nofile bufhidden=hide noswapfile nofen
				execute "setlocal filetype=".orig_ft
				call append(1, results)
				1d  " delete initial blank line
			endif
		endif
	endfunction
	" Delete the current buffer if it is a scratch buffer (any changes are lost).
	function! CloseScratch()
		if &buftype == "nofile" && &bufhidden == "hide" && !&swapfile
			" this is a scratch buffer
			bdelete
			return 1
		endif
		return 0
	endfunction
	nnoremap <silent> <Leader>f :call Gather(input("Search for: "))<CR>
	nnoremap <silent> <Leader>q :call CloseScratch()<CR>

endif


