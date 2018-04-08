runtime projects/ruby.vim

silent AckIgnore log/ tmp/ db/ public/assets/

runtime after/plugin/snippets.vim

augroup Project
  autocmd!

  " Snippets
  autocmd FileType ruby  set filetype=rails.ruby
  autocmd FileType eruby set filetype=rails.eruby
  autocmd FileType rspec set filetype=rails.rspec.ruby
augroup END

let g:rails_mappings = 0
