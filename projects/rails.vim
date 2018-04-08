runtime projects/ruby.vim

silent AckIgnore log/ tmp/ db/ public/assets/

runtime after/plugin/snippets.vim

augroup Project
  autocmd!

  " Snippets
  autocmd FileType ruby  UltiSnipsAddFiletypes rails_ruby
  autocmd FileType eruby UltiSnipsAddFiletypes rails_eruby
augroup END

let g:rails_mappings = 0
