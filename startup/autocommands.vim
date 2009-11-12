" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

autocmd FileType text setlocal textwidth=98

autocmd BufEnter *.cpp compiler gcc
autocmd BufEnter *.c compiler gcc

autocmd BufEnter *.php set filetype=php.html.javascript
autocmd BufEnter *.php compiler php

autocmd BufEnter *.html set filetype=html.javascript
autocmd BufEnter *.html compiler tidy

autocmd BufEnter *.js set filetype=javascript.jquery
autocmd BufEnter *.js compiler jsl

autocmd BufEnter *.hsc set filetype=haskell
autocmd BufEnter *.hs compiler ghc

autocmd BufEnter *.tags set filetype=tags

autocmd BufRead,BufNewFile *.vorg set filetype=vorg.txt
autocmd BufRead,BufNewFile *.mkd set filetype=mkd
autocmd BufRead,BufNewFile *.markdown set filetype=mkd

" Custom filetypes:
autocmd BufEnter Result set filetype=dbext_result.txt
autocmd BufEnter .passwords set filetype=yaml.passwords

" Maximise on open on Win32:
if has('win32')
  autocmd GUIEnter * simalt ~x
endif
