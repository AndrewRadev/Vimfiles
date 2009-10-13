setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab

compiler ruby

command! -buffer Console !irb -r %
