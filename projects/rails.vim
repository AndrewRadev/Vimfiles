runtime projects/ruby.vim

runtime after/plugin/snippets.vim

call ExtractSnipsFile(expand(g:snippets_dir).'rails.snippets', 'ruby')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_erb.snippets', 'eruby')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_rspec.snippets', 'rspec')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_haml.snippets', 'haml')
call ExtractSnipsFile(expand(g:snippets_dir).'jquery.snippets', 'javascript')

call ExtractSnipsFile('_snippets/ruby.snippets', 'ruby')
call ExtractSnipsFile('_snippets/rspec.snippets', 'rspec')
call ExtractSnipsFile('_snippets/javascript.snippets', 'javascript')

if !filereadable(fnamemodify('gems.tags', ':p'))
  " then we don't have gemtags, use static rails tags instead
  set tags+=~/tags/rails3.tags
endif

command! Rroutes edit config/routes.rb
command! Rschema edit db/schema.rb
command! -nargs=* -complete=custom,s:CompleteRailsModels Rmodel edit _project.vim | Rmodel <args>
command! -nargs=* -complete=custom,s:CompleteRailsFactory Rfactory call s:Rfactory(<f-args>)

command! DumpRoutes r! bundle exec rake routes
command! ReadCucumberSteps r!cucumber | sed -n -e '/these snippets/,$ p' | sed -n -e '2,$ p'

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = fnamemodify(file, ':t:r')
    call add(names, name)
  endfor
  return join(names, "\n")
endfunction

function! s:CompleteRailsFactory(A, L, P)
  let factories = []
  for line in split(system("grep -r 'Factory.define' spec/factories"), "\n")
    let factory = matchstr(line, 'Factory.define :\zs\w\+\ze')
    call add(factories, factory)
  endfor
  return join(factories, "\n")
endfunction

" TODO (2011-12-19) Extract factories with position data both for completion
" and editing
function! s:Rfactory(name)
  exe "Ack 'Factory.define :".a:name."\\b' spec/factories"
endfunction
