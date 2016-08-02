let b:surround_{char2nr('$')} = "$(\r)"
let b:outline_pattern = '\<function\>'
let b:dh_closing_pattern = '^\s*}'

setlocal foldmethod=indent
compiler eslint

nnoremap <buffer> gm :Doc js<cr>

" Reformat json
command! -buffer Reformat %!jsonpp
command! -buffer Unminify %!js-beautify -f -
