" Tagfiles:
set tags=./tags,tags
set tags+=~/tags/symfony.tags

" Custom snippets:
autocmd BufEnter *.php set filetype=php.html.javascript.symfony
" Base classes should never be modified:
autocmd BufEnter base/Base*.class.php set readonly

command! RebuildTags !ctags -R --exclude="*/symfony/*" --exclude="*/tmp/*" --languages=php .

command! RebuildAll     !php symfony doctrine:build-all-reload
command! RebuildAllTest !php symfony doctrine:build-all-reload --env=test
command! RebuildDb      !php symfony doctrine:build-db
command! RebuildModel   !php symfony doctrine:build-model
command! TestAll        !php symfony test:all
command! Run            !php %

command! Preview Utl ol http://localhost:80/

command! CC !php symfony cc
command! Sql tabedit data/sql/scratch.sql | normal _slt

runtime! macros/symfony_tasks.vim
runtime! macros/symfony_navigation.vim

command! Reformat silent! call Reformat()

function! Reformat()
  %s/\(\S\) {/\1\r{/g
  %s/} /}\r/g
  normal! '1G=G'
endfunction
