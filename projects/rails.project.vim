runtime after/plugin/snippets.vim

call ExtractSnipsFile(expand(g:snippets_dir).'rails.snippets', 'ruby')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_erb.snippets', 'eruby')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_rspec.snippets', 'rspec')
call ExtractSnipsFile(expand(g:snippets_dir).'jquery.snippets', 'javascript')

call ExtractSnipsFile('_snippets/ruby.snippets', 'ruby')
call ExtractSnipsFile('_snippets/javascript.snippets', 'javascript')
