setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

compiler python

command! -buffer -nargs=* Run !python3 % <args>
command! -buffer -complete=file -nargs=* Console !python3 -i % <args>
