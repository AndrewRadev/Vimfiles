" Define a text object for embedded code (<%= ... %>)
onoremap <buffer> a= :<c-u>call <SID>ErbTextObject('a')<cr>
xnoremap <buffer> a= :<c-u>call <SID>ErbTextObject('a')<cr>
onoremap <buffer> i= :<c-u>call <SID>ErbTextObject('i')<cr>
xnoremap <buffer> i= :<c-u>call <SID>ErbTextObject('i')<cr>
function! s:EcoTextObject(mode)
  if search('<%.*\%#.*%>', 'n') <= 0
    return
  endif

  if a:mode == 'i'
    let [start_flags, end_flags] = ['be', '']
  else " a:mode == 'a'
    let [start_flags, end_flags] = ['b', 'e']
  endif

  call search('<%=\?\s*.', start_flags, line('.'))
  let start = col('.') - 1
  call search('.\s*-\?%>', end_flags, line('.'))
  let end = col('.') - 1

  let interval = end - start

  exe 'normal! 0'.start.'lv'.interval.'l'
endfunction

autocmd Syntax * hi link coffeeSpecialVar Identifier
