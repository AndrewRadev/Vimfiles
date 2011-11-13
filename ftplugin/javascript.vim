let b:outline_pattern = '\<function\>'

setlocal foldmethod=indent

setlocal tags+=~/tags/jquery.tags

" Reformat json
command! -buffer Reformat %!jsonpp
command! -buffer Unminify %!js-beautify -
