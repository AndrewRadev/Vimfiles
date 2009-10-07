" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

autocmd FileType text setlocal textwidth=98

autocmd BufEnter *.php set filetype=php.html.javascript
autocmd BufEnter *.php compiler php

autocmd BufEnter *.html set filetype=html.javascript
autocmd BufEnter *.html compiler tidy

autocmd BufEnter *.js set filetype=javascript.jquery

autocmd BufEnter *.hsc set filetype=haskell
autocmd BufEnter *.hs compiler ghc

" Maximise on open on Win32:
if has('win32')
  autocmd GUIEnter * simalt ~x
endif
