command! -buffer Doc exe 'Open https://pypi.org/project/'..expand('<cword>')
nnoremap <buffer> gm :Doc<cr>
