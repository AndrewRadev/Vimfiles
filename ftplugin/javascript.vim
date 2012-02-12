let b:outline_pattern = '\<function\>'

setlocal foldmethod=indent

nnoremap <buffer> gm :Doc ruby<cr>

" Reformat json
command! -buffer Reformat %!jsonpp
command! -buffer Unminify %!js-beautify -
