setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

compiler python

setlocal foldmethod=indent
setlocal nofoldenable

RunCommand     !python3    %:S <args>
ConsoleCommand !python3 -i %:S <args>

let b:outline_pattern = '\v^\s*(def|class)(\s|$)'

let b:match_words = '\<if\>:\<elsif\>:\<else\>'
let b:match_skip = 'R:^\s*'

" Indent guides
setlocal listchars=leadmultispace:\┊\ \ \ ,
setlocal list
hi SpecialKey ctermfg=DarkGray
