runtime! projects/rails.project.vim

augroup project
  autocmd!

  autocmd Filetype rspec.ruby RunCommand !rspec % --format=documentation
  autocmd BufEnter Gemfile RunCommand !bundle install
augroup END

set tags+=~/tags/rails33.tags
