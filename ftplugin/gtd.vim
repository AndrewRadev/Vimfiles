" Vim filetype plugin file
" Language:     GTD
" Maintainer:   William Bartholomew <william@bartholomew.id.au>
" Last Change:  2006-07-13

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

" Allow @ and : in keywords.
setlocal iskeyword="a-z,A-Z,0-9,@,:"

" Add commands.
command -nargs=? GtdNewTask call <SID>GtdNewTask( <q-args> )
command -nargs=* GtdAddContext call <SID>GtdAddContext( <f-args> )
command -nargs=? GtdAssignProject call <SID>GtdAssignProject( <q-args> )
command -nargs=0 GtdMarkDone call <SID>GtdMarkDone()
command -nargs=0 GtdSort call <SID>GtdSort()

" Add GTD menu.
noremenu <silent> &GTD.&New\ Task	:GtdNewTask<CR>
noremenu <silent> &GTD.Mark\ &Done	:GtdMarkDone<CR>
noremenu <silent> &GTD.Add\ &Context	:GtdAddContext<CR>
noremenu <silent> &GTD.Assign\ &Project	:GtdAssignProject<CR>
noremenu <silent> &GTD.Re-&Sort		:GtdSort<CR>

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_gtd_maps")
    noremap  <silent> <LocalLeader>n	:GtdNewTask<CR>
    noremap  <silent> <LocalLeader>d	:GtdMarkDone<CR>
    noremap  <silent> <LocalLeader>c	:GtdAddContext<CR>
    noremap  <silent> <LocalLeader>p	:GtdAssignProject<CR>
    noremap  <silent> <LocalLeader>s	:GtdSort<CR>
endif

function! s:GtdNewTask( task )
    if a:task == ""
	let task = input( "GTD Task Description: " )
    else
	let task = a:task
    endif
    if task != ""
	let current_time = strftime("%Y%m%d")
	let task = task . " [" . current_time . "]"

	if match( getline( "." ), "^$" ) == 0
	    call setline( ".", task )
	else
	    call append( 0, task )
	endif
	call <SID>GtdSort()
	write

	"let [lnum, col] = searchpos( "^" . task . "$" )
	"call cursor( [lnum, col] )

	call search( "^" . task . "$", "w" )
    endif
endfunction

function! s:GtdMarkDone()
    let current_line = getline( "." )

    if !<SID>GtdIsTaskDone( current_line )
	let current_time = strftime("%Y%m%d")

	call setline( ".", "x:" . current_time . " " . current_line )
	call <SID>GtdSort()
	write
    endif
endfunction

function! s:GtdAssignProject( project_name )
    if a:project_name == ""
	let project_name = input( "GTD Project Name: " )
    else
	let project_name = a:project_name
    endif
    if project_name != ""
	let project_tag = "p:" . project_name

	let current_line = getline( "." )
	if stridx( current_line, "p:" ) == -1
	    call setline( ".", project_tag . " " . current_line )
	else
	    call setline( ".", substitute( current_line, "p:\\S\\+", project_tag, "" ) )
	endif

	call <SID>GtdSort()
	write
    endif
endfunction

function! s:GtdAddContext( ... )
    if a:0 == 0
        call <SID>GtdAddContext( input( "GTD Context: " ) )
	return
    endif

    let current_line = getline( "." )

    let index = a:0
    while index >= 1
	let context = a:{index}
	if stridx( context, "@" ) == -1
	    let context = "@" . context
	endif

	if stridx( current_line, context ) == -1
	    let current_line = substitute( current_line, "^\\(p:\\S\\+\\s\\?\\)\\?", "\\1" . context . " ", "" )
	endif

	let index = index - 1
    endwhile

    call setline( ".", current_line )

    call <SID>GtdSort()
    write
endfunction

function! s:GtdIsTaskDone( task )
    return ( match( a:task, "^x[ :]" ) > -1 )
endfunction

function! s:GtdSort()
    if executable( "sort" )
	%! sort
    endif
endfunction
