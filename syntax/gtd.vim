runtime! syntax/txt.vim

" syntax case ignore

syntax match gtdSection /==[^=]*/ display fold
syntax match gtdProject /=[^=].*/ display fold

hi link gtdSection Underlined
hi link gtdProject Identifier
