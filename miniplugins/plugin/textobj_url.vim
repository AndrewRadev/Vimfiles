" Note: depends on splitjoin

onoremap iu :<c-u>call <SID>UrlTextObject()<cr>
xnoremap iu :<c-u>call <SID>UrlTextObject()<cr>
onoremap au :<c-u>call <SID>UrlTextObject()<cr>
xnoremap au :<c-u>call <SID>UrlTextObject()<cr>

function! s:UrlTextObject()
  let url_pattern = '\(http\|https\|ftp\|file\)://\f\%(\f\|[@?!=&]\)*'
  if sj#SearchUnderCursor(url_pattern) <= 0
    return
  endif
  let cfile = expand('<cfile>')

  let start_position = getpos('.')
  call sj#SearchUnderCursor(url_pattern, 'e')
  let end_position = getpos('.')

  let saved_z_pos = getpos("'z")
  call setpos('.', start_position)
  call setpos("'z", end_position)

  normal! v`z

  call setpos("'z", saved_z_pos)
endfunction
