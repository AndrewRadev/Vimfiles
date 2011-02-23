setlocal tabstop=8
setlocal shiftwidth=8
setlocal noexpandtab

iabbr null NULL

nmap <buffer> gm :exe "Man ".expand("<cword>")<cr>

RunCommand !./a.out <args>
