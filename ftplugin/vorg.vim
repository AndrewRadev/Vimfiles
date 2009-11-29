nmap <buffer> ,c ma0t]rx`a
nmap <buffer> ,u ma0t]r `a
nmap <buffer> <F7> mz:m+<CR>==`z
nmap <buffer> <F6> mz:m-2<CR>==`z

" Shift lines up and down
nnoremap <buffer> <C-j> mz:m+<CR>`z
nnoremap <buffer> <C-k> mz:m-2<CR>`z
inoremap <buffer> <C-j> <Esc>:m+<CR>gi
inoremap <buffer> <C-k> <Esc>:m-2<CR>gi
vnoremap <buffer> <C-j> :m'>+<CR>gv=`<my`>mzgv`yo`z
vnoremap <buffer> <C-k> :m'<-2<CR>gv=`>my`<mzgv`yo`z

nnoremap <buffer> <C-o> :/[-\*]\ *\[\ \].*@
nnoremap <buffer> <C-t> :/-.*(.*.*)<LEFT><LEFT><LEFT>
