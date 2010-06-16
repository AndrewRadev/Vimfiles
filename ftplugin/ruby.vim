setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=syntax

setlocal tags+=~/tags/ruby.tags
setlocal tags+=~/tags/gems.tags

compiler ruby

" surround area with <foo> (...) { }
let b:surround_{char2nr('i')} = "if \1if: \1 \r end"
let b:surround_{char2nr('w')} = "while \1while: \1 do \r end"
let b:surround_{char2nr('e')} = "\1collection: \1.each do |\2item: \2| \r end"

command! -buffer -nargs=* Console !irb -r % <args>

if expand('%') =~ '_spec.rb'
  command! -buffer -complete=file -nargs=* Run !spec --color --format specdoc % <args>
else
  command! -buffer -complete=file -nargs=* Run !ruby % <args>
endif
