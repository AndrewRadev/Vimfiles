if !has('ruby')
  finish
endif

call ResetSnippets()

call ExtractSnipsFile(g:snippets_dir.'_.snippets', '_')
call ExtractSnipsFile(g:snippets_dir.'html.snippets', 'php')
call ExtractSnipsFile(g:snippets_dir.'javascript.snippets', 'html')
call ExtractSnipsFile(g:snippets_dir.'html.snippets', 'eruby')
call ExtractSnipsFile(g:snippets_dir.'html.snippets', 'eco')
call ExtractSnipsFile(g:snippets_dir.'css.snippets', 'scss')
call ExtractSnipsFile(g:snippets_dir.'css.snippets', 'less')
call ExtractSnipsFile(g:snippets_dir.'help.snippets', 'help')
