setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

command! -buffer Run !python3 %
command! -buffer Console !python3 -i %
