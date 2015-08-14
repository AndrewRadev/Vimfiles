silent AckIgnore tmp/ bower_components/ node_modules/

runtime after/plugin/snippets.vim

call ExtractSnipsFile(expand(g:snippets_dir).'ember.snippets', 'javascript')
