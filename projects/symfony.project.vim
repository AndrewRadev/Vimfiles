" Tagfiles:
set tags=
set tags+=symfony.tags

" Dbext profile -- expand snip with "dbext<tab>"

" Autotag settings:
let g:autotagCtagsCmd = "ctags --sort=foldcase"

command! RebuildTags !ctags -R --exclude=symfony --sort=foldcase .
command! RebuildDb !php symfony doctrine:build-all-reload
command! TestAll !php symfony test:all
command! Run !php %
command! Preview Utl ol http://localhost/

command! CC !php symfony cc
