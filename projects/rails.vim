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
" command! -nargs=* -complete=custom,s:CompleteRailsFactory Rfactory edit _project.vim | Rfactory <args>

command! DumpRoutes r! bundle exec rake routes

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = fnamemodify(file, ':t:r')
    call add(names, name)
  endfor
  return join(names, "\n")
endfunction

function! s:CompleteRailsFactory(A, L, P)
  " TODO (2011-12-16)
endfunction
