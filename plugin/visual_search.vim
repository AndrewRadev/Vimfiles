" By Amir Salihefendic
" From an idea by Michael Naumann
function! VisualSearch(direction) range
  let l:saved_reg = @"
  execute "normal! vgvy"
  let l:pattern = escape(@", '\\/.*$^~[]')
  let l:pattern = substitute(l:pattern, "\n$", "", "")
  if a:direction == 'b'
    execute "normal ?" . l:pattern . ""
  else
    execute "normal /" . l:pattern . ""
  endif
  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

xnoremap * :call VisualSearch('f')<CR>
xnoremap # :call VisualSearch('b')<CR>
