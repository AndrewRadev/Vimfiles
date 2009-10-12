" Tagfiles:
set tags=
set tags+=symfony.tags

" Dbext profile -- expand snip with "dbext<tab>"

" Autotag settings:
let g:autotagCtagsCmd = "ctags --sort=foldcase"

command! CC !php symfony cc
