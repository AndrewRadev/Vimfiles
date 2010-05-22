setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=syntax

setlocal tags+=~/tags/ruby.tags
setlocal tags+=~/tags/gems.tags

compiler ruby

command! -buffer -nargs=* Console !irb -r % <args>
command! -buffer -complete=file -nargs=* Run !ruby % <args>
