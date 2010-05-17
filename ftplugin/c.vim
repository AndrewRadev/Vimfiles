iabbr null NULL

nmap <buffer> gm :exe "Man ".expand("<cword>")<cr>

command! -buffer -nargs=* Run !./a.out <args>
