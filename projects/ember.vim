silent AckIgnore tmp/ bower_components/ node_modules/ dist/

runtime after/plugin/snippets.vim

call ExtractSnipsFile(g:snippets_dir.'ember_js.snippets', 'javascript')
call ExtractSnipsFile(g:snippets_dir.'ember_coffee.snippets', 'coffee')
