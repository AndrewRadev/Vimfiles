" Tagfiles:
set tags=
set tags+=symfony.tags

" Custom snippets:
autocmd BufEnter *.php set filetype=php.html.javascript.symfony

" Dbext profile -- expand snip with "dbext<tab>"

" Autotag settings:
let g:autotagCtagsCmd = "ctags --sort=foldcase"

command! RebuildTags !ctags -R --exclude=symfony --sort=foldcase .
command! RebuildDb !php symfony doctrine:build-all-reload & php symfony doctrine:build-all-reload --env=test -F
command! TestAll !php symfony test:all
command! Run !php %
command! Preview Utl ol http://localhost/

command! CC !php symfony cc
