setlocal foldmethod=indent
setlocal foldenable

RunCommand CoffeePreviewToggle

nnoremap s; :call <SID>ToggleFunctionDefinition()<cr>
function! s:ToggleFunctionDefinition()
  let line = getline('.')

  let saved_cursor = getpos('.')

  if line =~ '^\s*\k\+:'
    s/:/ =/
  elseif line =~ '^\s*\k\+\s\+='
    s/\s*=\s*/: /
  endif

  call setpos('.', saved_cursor)
endfunction

nnoremap <buffer> gm :Doc js<cr>

nmap <buffer> - <Plug>CoffeeToolsToggleFunctionArrow
xmap <buffer> sO <Plug>CoffeeToolsOpenLineAndIndent
nmap <buffer> dh <Plug>CoffeeToolsDeleteAndDedent

autocmd Syntax * hi link coffeeSpecialVar Identifier
