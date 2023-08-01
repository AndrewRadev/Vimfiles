function! s:VisualSearch(direction) range
  let saved_register_text = getreg('z', 1)
  let saved_register_type = getregtype('z')
  defer setreg('z', saved_register_text, saved_register_type)

  execute 'normal! vgv"zy'
  let pattern = trim(@z)
  let pattern = '\V' . escape(pattern, '\')

  if a:direction == 'b'
    call search(pattern, 'b')
  else
    call search(pattern)
  endif

  let @/ = pattern
endfunction

xnoremap * :call <SID>VisualSearch('f')<CR>
xnoremap # :call <SID>VisualSearch('b')<CR>
