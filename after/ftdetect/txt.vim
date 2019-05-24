" Set txt filetype by default, unless it was already set to "FALLBACK html"
au BufRead,BufNewFile * if &ft != 'html' | setfiletype txt | endif
