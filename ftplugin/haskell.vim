"
" general Haskell source settings
" (shared functions are in autoload/haskellmode.vim)
"
" (Claus Reinke, last modified: 28/04/2009)
"
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim
" please send patches to <claus.reinke@talk21.com>

" try gf on import line, or ctrl-x ctrl-i, or [I, [i, ..
setlocal include=^import\\s*\\(qualified\\)\\?\\s*
setlocal includeexpr=substitute(v:fname,'\\.','/','g').'.'
setlocal suffixesadd=hs,lhs,hsc

command! -buffer -nargs=* Console !ghci % <args>
command! -buffer -nargs=* Run !runhaskell % <args>

nmap <buffer> gm :exe ":Search hoogle " . expand("<cword>")<cr>

xnoremap <buffer> <Leader>a: :Align \:\:<cr>
xnoremap <buffer> <Leader>a- :Align <-<cr>:'<,'>Align -><cr>
