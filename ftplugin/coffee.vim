setlocal foldmethod=indent
setlocal foldenable

RunCommand CoffeePreviewToggle

nnoremap - :call <SID>ToggleFunctionType()<cr>
function! s:ToggleFunctionType()
  let line = getline('.')

  let saved_cursor = getpos('.')
  if line =~ '=>$'
    s/=>$/->/
  elseif line =~ '->$'
    s/->$/=>/
  endif
  call setpos('.', saved_cursor)
endfunction

nnoremap <buffer> gm :Doc javascript<cr>
xmap <buffer> sO <Plug>CoffeeToolsOpenLineAndIndent

autocmd Syntax * hi link coffeeSpecialVar Identifier
