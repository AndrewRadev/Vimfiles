let b:surround_{char2nr('$')} = "$(\r)"
let b:outline_pattern = '\<function\>'
let b:deleft_closing_pattern = '^\s*}'

let b:extract_var_template = 'const %s = %s;'
let b:extract_prefix_template = '\%(var\|let\|const\)\s*\zs\k\+\ze\s*='
let b:inline_var_pattern   = '\%(var\|let\|const\)\s\+\(\k\+\)\s\+=\s\+\(.\{-}\);\='

setlocal foldmethod=indent
compiler eslint

nnoremap <buffer> gm :Doc js<cr>

" Reformat json
command! -buffer Reformat %!jq .
command! -buffer Unminify %!js-beautify -f -

RunCommand !node % <args>
