" By Amir Salihefendic
" From an idea by Michael Naumann
function! s:VisualSearch(direction) range
  let saved_register_text = getreg('z', 1)
  let saved_register_type = getregtype('z')

  execute "normal! vgv\"zy"
  let pattern = escape(@z, '\\/.*$^~[]')
  let pattern = substitute(pattern, "\n$", "", "")

  if a:direction == 'b'
    execute "normal! ?" . pattern . "\<cr>"
  else
    execute "normal! /" . pattern . "\<cr>"
  endif

  let @/ = pattern
  call setreg('z', saved_register_text, saved_register_type)
endfunction

xnoremap * :call <SID>VisualSearch('f')<CR>
xnoremap # :call <SID>VisualSearch('b')<CR>
