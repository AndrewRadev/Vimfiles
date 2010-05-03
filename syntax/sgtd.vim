runtime! syntax/txt.vim

syntax case ignore

syntax match gtdSection /==[^=]*/  display fold
syntax match gtdProject /=[^=].*/  display fold
syntax match gtdDate    /date: .*/ display
syntax match gtdTag     /@\k*/     display

syntax match gtdImportant /!important/ display

hi link gtdSection   Underlined
hi link gtdProject   Identifier
hi link gtdDate      Todo
hi link gtdImportant Error
hi link gtdTag       Tag
