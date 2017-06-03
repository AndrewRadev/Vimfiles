let b:surround_{char2nr('$')} = "$(\r)"
let b:outline_pattern = '\<function\>'
let b:deleft_closing_pattern = '^\s*}'

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = '\%(var\|let\)\s\+\(\k\+\)\s\+=\s\+\(.\{-}\);\='

setlocal foldmethod=indent
compiler eslint

nnoremap <buffer> gm :Doc js<cr>

" Reformat json
command! -buffer Reformat %!jq .
command! -buffer Unminify %!js-beautify -f -
