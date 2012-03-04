let b:surround_{char2nr('-')} = "<% \r %>"
let b:surround_{char2nr('=')} = "<%= \r %>"
" surround area with <% <foo> (...) do %> <% end %>
let b:surround_{char2nr('I')} = "<% if \1<% if: \1 %> \r <% end %>"
let b:surround_{char2nr('U')} = "<% unless \1<% unless: \1 %> \r <% end %>"

nnoremap - :call <SID>ToggleEscaping()<cr>
function! s:ToggleEscaping()
  let line = getline('.')

  let saved_cursor = getpos('.')
  if line =~ '<%='
    s/<%=/<%-/
  elseif line =~ '<%-'
    s/<%-/<%=/
  endif
  call setpos('.', saved_cursor)
endfunction

" Define a text object for embedded code (<%= ... %>)
onoremap <buffer> a= :<c-u>call <SID>EcoTextObject('a')<cr>
xnoremap <buffer> a= :<c-u>call <SID>EcoTextObject('a')<cr>
onoremap <buffer> i= :<c-u>call <SID>EcoTextObject('i')<cr>
xnoremap <buffer> i= :<c-u>call <SID>EcoTextObject('i')<cr>
function! s:EcoTextObject(mode)
  if search('<%.*\%#.*%>', 'n') <= 0
    return
  endif

  if a:mode == 'i'
    let [start_flags, end_flags] = ['be', '']
  else " a:mode == 'a'
    let [start_flags, end_flags] = ['b', 'e']
  endif

  call search('<%[=-]\?\s*.', start_flags, line('.'))
  let start = col('.') - 1
  call search('.\s*%>', end_flags, line('.'))
  let end = col('.') - 1

  let interval = end - start

  if start == 0
    exe 'normal! 0v'.interval.'l'
  else
    exe 'normal! 0'.start.'lv'.interval.'l'
  endif
endfunction

autocmd Syntax * hi link coffeeSpecialVar Identifier
