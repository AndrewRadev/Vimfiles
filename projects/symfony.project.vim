" Tagfiles:
set tags=./tags,tags
set tags+=~/tags/symfony.tags

" Custom snippets:
autocmd BufEnter *.php set filetype=php.html.javascript.symfony
" Base classes should never be modified:
autocmd BufEnter base/Base*.class.php set readonly

command! RebuildTags !ctags -R --exclude=symfony,tmp --languages=php .

command! RebuildAll   !php symfony doctrine:build-all-reload
command! RebuildDb    !php symfony doctrine:build-db
command! RebuildModel !php symfony doctrine:build-model
command! TestAll      !php symfony test:all
command! Run          !php %

command! Preview Utl ol http://localhost:80/

command! CC !php symfony cc
command! Sql tabedit data/sql/scratch.sql | normal \slt

runtime! macros/symfony_tasks.vim
runtime! macros/symfony_navigation.vim
