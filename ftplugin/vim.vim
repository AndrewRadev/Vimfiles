setlocal foldmethod=indent

" For <C-]> to be able to detect:
" - autoloaded functions
" - mappings,
" - variables with a scope prefix
setlocal iskeyword+=:,#,<,>

let b:surround_{char2nr('i')} = "if \1if: \1 \r endif"
let b:surround_{char2nr('w')} = "while \1while: \1 \r endwhile"
let b:surround_{char2nr('f')} = "for \1for: \1 {\r endfor"
let b:surround_{char2nr('e')} = "foreach \1foreach: \1 \r enforeach"
let b:surround_{char2nr('F')} = "function! \1function: \1() \r endfunction"

let b:outline_pattern = '\<\(function\|command\)\>'

nmap <buffer> gm :exe "help ".expand("<cword>")<cr>

RunCommand so %

setlocal includeexpr=lib#VimIncludeExpression(v:fname)
