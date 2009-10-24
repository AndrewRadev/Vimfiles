" Tagfiles:
set tags=./tags,tags
set tags+=symfony.tags

" Custom snippets:
autocmd BufEnter *.php set filetype=php.html.javascript.symfony
" Base* classes should never be modified:
autocmd BufEnter Base*.class.php set readonly

" Dbext profile goes here -- expand snip with "dbext<tab>":

" Autotag settings:
let g:autotagCtagsCmd = "ctags --sort=foldcase"

command! RebuildTags silent !ctags -R --exclude=symfony,tmp --sort=foldcase --languages=php .
command! RebuildDb silent
      \ !php symfony doctrine:build-all-reload 
      \ & php symfony doctrine:build-all-reload --env=test -F
command! TestAll !php symfony test:all
command! Run !php %
command! Preview Utl ol http://localhost:80/

command! CC silent !php symfony cc
