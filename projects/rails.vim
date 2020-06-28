runtime projects/ruby.vim

silent AckIgnore log/ tmp/ db/ public/assets/
silent TagsExclude tmp/* node_modules/* db/* public/assets/*

command! Eroutes edit config/routes.rb
command! -nargs=* -complete=custom,rails_extra#edit#CompleteSchema
      \ Eschema call rails_extra#edit#Schema(<q-args>)
command! -nargs=* -complete=custom,rails_extra#edit#CompleteFactories
      \ Efactory call rails_extra#edit#Factory(<q-args>)

command! -nargs=1 -complete=custom,s:CompleteRailsModels Emodel call s:Emodel(<q-args>)

function! s:Emodel(model_name)
  let model_name = rails#singularize(rails#underscore(a:model_name))
  exe 'edit app/models/'.model_name.'.rb'
endfunction

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = file
    let name = substitute(name, '^app/models/', '', '')
    let name = substitute(name, '\.rb$', '', '')

    call add(names, name)
  endfor
  return join(names, "\n")
endfunction

augroup Project
  autocmd!

  " Snippets
  " autocmd FileType ruby  UltiSnipsAddFiletypes rails_ruby
  " autocmd FileType eruby UltiSnipsAddFiletypes rails_eruby
augroup END

let g:rails_mappings = 0
