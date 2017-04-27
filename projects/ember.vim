silent AckIgnore tmp/ bower_components/ node_modules/ dist/

augroup Project
  autocmd!

  " Snippets
  autocmd FileType javascript set filetype=ember.javascript
  autocmd FileType coffee set filetype=ember.coffee
augroup END
