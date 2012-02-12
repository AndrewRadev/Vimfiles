" Go to manual
nnoremap gm :Doc css<cr>

" Work on a CSS definition in the current line
" Origin is "delete an argument", similar to arguments of functions
onoremap <buffer> aa :<c-u>call <SID>DefinitionTextObject('a')<cr>
xnoremap <buffer> aa :<c-u>call <SID>DefinitionTextObject('a')<cr>
onoremap <buffer> ia :<c-u>call <SID>DefinitionTextObject('i')<cr>
xnoremap <buffer> ia :<c-u>call <SID>DefinitionTextObject('i')<cr>
function! s:DefinitionTextObject(mode)
  if search('{.*\%#.*}', 'n') <= 0
    return
  endif

  if a:mode == 'i'
    let [start_flags, end_flags] = ['be', '']
  else " a:mode == 'a'
    let [start_flags, end_flags] = ['be', 'e']
  endif

  call search('\({\|;\).', start_flags, line('.'))
  let start_col = col('.') - 1
  call search('.\(}\|;\)', end_flags, line('.'))
  let end_col = col('.') - 1

  let interval = end_col - start_col

  exe 'normal! 0'.start_col.'lv'.interval.'l'
endfunction
