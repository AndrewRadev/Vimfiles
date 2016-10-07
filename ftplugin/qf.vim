setlocal nowrap

syntax match quickfixComment '^||.*$'
hi link quickfixComment Comment

nnoremap <buffer> <cr> <cr>

nnoremap <buffer> <c-w>< :colder<cr>
nnoremap <buffer> <c-w>> :cnewer<cr>
