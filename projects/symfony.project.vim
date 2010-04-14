" Tagfiles:
set tags=./tags,tags
set tags+=~/tags/symfony.tags

" Cscope database:
if filereadable('./cscope.out')
  cscope add cscope.out
endif

command! RebuildCscope !find . -name *.php > cscope.files && cscope -b

" Custom snippets:
runtime after/plugin/snippets.vim
call ExtractSnipsFile(expand(g:snippets_dir).'symfony.snippets', 'php')
call ExtractSnipsFile(expand(g:snippets_dir).'jquery.snippets', 'javascript')

" Base classes should never be modified:
autocmd BufEnter base/Base*.class.php set readonly

command! RebuildTags !ctags -R --exclude="symfony" .

command! RebuildAll     !php symfony --color doctrine:build --all
command! RebuildAllTest !php symfony --color doctrine:build --all --env=test
command! RebuildClasses !php symfony --color doctrine:build --all-classes
command! TestAll        !php symfony --color test:all
command! Migrate        !php symfony --color doctrine:migrate

let s:sf_generate_commands = {
      \ 'migration': 'doctrine:generate-migration',
      \ 'app':       'generate:app',
      \ 'module':    'generate:module',
      \ }

command! -nargs=* -complete=customlist,s:CompleteGenerate Generate call s:Generate(<f-args>)
function! s:Generate(what, ...)
  let l:command = s:sf_generate_commands[a:what]
  exe "!php symfony --color ".l:command." ".join(a:000)
endfunction
function! s:CompleteGenerate(A, L, P)
  return sort(keys(filter(copy(s:sf_generate_commands), "v:key =~'^".a:A."'")))
endfunction

command! Preview Utl ol http://localhost:80/

command! CC !php symfony --color cc

runtime! scripts/symfony/navigation.vim
runtime! scripts/symfony/includeexpr.vim
