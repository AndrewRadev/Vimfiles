setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal tags+=~/tags/ruby.tags

compiler ruby

command! -buffer Console !irb -r %
command! -buffer Run !ruby %
