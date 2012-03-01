setlocal foldmethod=indent
setlocal nofoldenable

RunCommand CoffeePreviewToggle

nnoremap <buffer> gm :Doc javascript<cr>

nmap <buffer> dh <Plug>CoffeeToolsDeleteLineAndDedent
xmap <buffer> sO <Plug>CoffeeToolsOpenLineAndIndent

autocmd Syntax * hi link coffeeSpecialVar Identifier
