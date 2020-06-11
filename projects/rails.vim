runtime projects/ruby.vim

silent AckIgnore log/ tmp/ db/ public/assets/
silent TagsExclude tmp/* node_modules/* db/* public/assets/*

command! Eroutes edit config/routes.rb
command! -nargs=* -complete=custom,rails_extra#edit#CompleteSchema
      \ Eschema call rails_extra#edit#Schema(<q-args>)
command! -nargs=* -complete=custom,rails_extra#edit#CompleteFactories
      \ Efactory call rails_extra#edit#Factory(<q-args>)

augroup Project
  autocmd!

  " Snippets
  " autocmd FileType ruby  UltiSnipsAddFiletypes rails_ruby
  " autocmd FileType eruby UltiSnipsAddFiletypes rails_eruby
augroup END

let g:rails_mappings = 0
