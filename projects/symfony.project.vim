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

let g:symfony_command = '!php symfony --color'

function! SfExec(cmd)
  exe g:symfony_command.' '.a:cmd
endfunction

command! RebuildTags !ctags -R --exclude="symfony" .

command! RebuildAll     call SfExec('doctrine:build --all --and-load')
command! RebuildAllTest call SfExec('doctrine:build --all --env=test')
command! RebuildModel   call SfExec('doctrine:build --all-classes')
command! TestAll        call SfExec('test:all')
command! Migrate        call SfExec('doctrine:migrate')
command! CC             call SfExec('cc')

let s:sf_generate_commands = {
      \ 'migration': 'doctrine:generate-migration',
      \ 'app':       'generate:app',
      \ 'module':    'generate:module',
      \ }

command! -nargs=* -complete=customlist,s:CompleteGenerate Generate call s:Generate(<f-args>)
function! s:Generate(what, ...)
  let l:command = s:sf_generate_commands[a:what]
  call SfExec(l:command." ".join(a:000))
endfunction
function! s:CompleteGenerate(A, L, P)
  return sort(keys(filter(copy(s:sf_generate_commands), "v:key =~'^".a:A."'")))
endfunction

command! Preview Utl ol http://localhost

runtime! scripts/symfony/navigation.vim
runtime! scripts/symfony/includeexpr.vim
set includeexpr=SymfonyIncludeExpr(v:fname)
