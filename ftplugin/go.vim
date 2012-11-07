set noexpandtab
set tabstop=4
set shiftwidth=4
set makeprg=go\ run\ %

" override go vimfiles mapping
nnoremap <buffer> K 5gk

nmap <buffer> gm <Plug>(godoc-keyword)

RunCommand !go run %
