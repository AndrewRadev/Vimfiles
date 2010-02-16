" Tagfiles:
set tags=./tags,tags
set tags+=~/tags/symfony.tags

" Custom snippets:
runtime after/plugin/snippets.vim
call ExtractSnipsFile(expand(g:snippets_dir).'symfony.snippets', 'php')
call ExtractSnipsFile(expand(g:snippets_dir).'jquery.snippets', 'javascript')

" Base classes should never be modified:
autocmd BufEnter base/Base*.class.php set readonly

command! RebuildTags !ctags -R --exclude="symfony" --languages=php .

command! RebuildAll     !php symfony doctrine:build-all-reload
command! RebuildAllTest !php symfony doctrine:build-all-reload --env=test
command! RebuildDb      !php symfony doctrine:build-db
command! RebuildModel   !php symfony doctrine:build-model
command! TestAll        !php symfony test:all
command! Migrate        !php symfony doctrine:migrate

command! Preview Utl ol http://localhost:80/

command! CC !php symfony cc
command! Sql tabedit data/sql/scratch.sql | normal _slt

runtime! scripts/symfony/tasks.vim
runtime! scripts/symfony/navigation.vim
runtime! scripts/symfony/includeexpr.vim
