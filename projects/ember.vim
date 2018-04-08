silent AckIgnore tmp/ bower_components/ node_modules/ dist/

augroup Project
  autocmd!

  " Snippets
  autocmd FileType javascript UltiSnipsAddFiletypes ember_javascript
  autocmd FileType coffee     UltiSnipsAddFiletypes ember_coffeescript
augroup END
