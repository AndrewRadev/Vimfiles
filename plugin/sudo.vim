"
"
"	sudo.vim:  A vim plugin by Rich Paul (vim@rich-paul.net)
"	
"	This script eases use of vim with sudo by adding the ability to
"	edit one file with root privleges without running the whole 
"	session that way.
"
"
"	Usage:  put it in the plugin directory, and
"			(command line): vim sudo:/etc/passwd
"			(within vim):   :e sudo:/etc/passwd
"
"		sudo will ask for your password if need be.
"	Requires:
"		sudo package installed
"		decent OS (sorry, no windows, unless cygwin has sudo now?)
"	Provides:
"		URL handler, sudo: scheme
"		2 autocommands
"		
"	Commands:
"		SudoRead
"		SudoWrite
"	ToDo:
"		Allow one to sudo to users other than root.
"		Quote the file name better.
"


if exists("s:seen") && !exists("s:debug")
	finish
endif
let s:seen=1
"let s:debug=1
function! SudoRead(url)
	if a:url=="<afile>"
		let file=expand(a:url)
	else
		let file=a:url
	endif
	let prot=matchstr(file,'^\(sudo\)\ze:')
	if '' != prot
		let file=strpart(file,strlen(prot)+1)
	endif
	:0,$d
	call setline(1,"foo")		
	exec '1read !sudo cat "'.file.'" '
	:1d
	set nomod
	:filetype detect
endfunction
function! SudoWrite (url) abort
	if a:url=="<afile>"
		let file=expand(a:url)
	else
		let file=a:url
	endif
	let prot=matchstr(file,'^\(sudo\)\ze:')
	if '' != prot
		let file=strpart(file,strlen(prot)+1)
	endif
	set nomod
	exec '%write !sudo tee >/dev/null "'.file.'"'
endf
command! -nargs=1 SudoRead call SudoRead(<f-args>)
command! -nargs=1 SudoWrite call SudoWrite(<f-args>)
augroup Sudo
	autocmd!
	au BufReadCmd	sudo:*,sudo:*/* SudoRead <afile>
	au FileReadCmd	sudo:*,sudo:*/* SudoRead <afile>
	au BufWriteCmd	sudo:*,sudo:*/* SudoWrite <afile>
	au FileWriteCmd	sudo:*,sudo:*/* SudoWrite <afile>
augroup END
