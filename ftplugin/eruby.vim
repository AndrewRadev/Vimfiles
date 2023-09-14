setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=indent

let b:surround_{char2nr('-')} = "<% \r %>"
let b:surround_{char2nr('=')} = "<%= \r %>"
let b:surround_{char2nr('t')} = "<%=t '\r' %>"

" surround area with <% <foo> (...) do %> <% end %>
let b:surround_{char2nr('i')} = "<% if \1<% if: \1 %> \r <% end %>"
let b:surround_{char2nr('u')} = "<% unless \1<% unless: \1 %> \r <% end %>"
let b:surround_{char2nr('w')} = "<% while \1<% while: \1 do %> \r <% end %>"
let b:surround_{char2nr('e')} = "<% \1<% collection: \1.each do |\2item: \2| %> \r <% end %>"
let b:surround_{char2nr('d')} = "<% do %> \r <% end %>"

RunCommand !erb % <args>

let b:extract_var_template = '<%% %s = %s %%>'
let b:extract_prefix_template = '<%% \zs\k\+\ze ='

" Define a text object for erb segments (<%= ... %>)
onoremap <buffer> a= :<c-u>call <SID>ErbTextObject('a')<cr>
xnoremap <buffer> a= :<c-u>call <SID>ErbTextObject('a')<cr>
onoremap <buffer> i= :<c-u>call <SID>ErbTextObject('i')<cr>
xnoremap <buffer> i= :<c-u>call <SID>ErbTextObject('i')<cr>
function! s:ErbTextObject(mode)
  if sj#SearchUnderCursor('<%.\{-}%>', '') <= 0
    return
  endif

  if a:mode == 'i'
    call search('<%=\?\s*\S', 'e', line('.'))
  endif
  let start = virtcol('.')

  if a:mode == 'i'
    let end_flags = ''
  else
    let end_flags = 'e'
  endif

  call search('\S\s*-\?%>', end_flags, line('.'))
  let end = virtcol('.')

  if start == 0
    exe 'normal! 0v'.end.'|'
  else
    exe 'normal! 0'.start.'|v'.end.'|'
  endif
endfunction

" To be sure it's an erb file
let b:erb_loaded = 1
