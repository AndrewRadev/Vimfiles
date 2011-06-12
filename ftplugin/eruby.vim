let b:surround_{char2nr('-')} = "<% \r %>"
let b:surround_{char2nr('=')} = "<%= \r %>"
" surround area with <% <foo> (...) do %> <% end %>
let b:surround_{char2nr('I')} = "<% if \1<% if: \1 %> \r <% end %>"
let b:surround_{char2nr('U')} = "<% unless \1<% unless: \1 %> \r <% end %>"
let b:surround_{char2nr('W')} = "<% while \1<% while: \1 do %> \r <% end %>"
let b:surround_{char2nr('E')} = "<% \1<% collection: \1.each do |\2item: \2| %> \r <% end %>"
let b:surround_{char2nr('D')} = "<% do %> \r <% end %>"

RunCommand !erb % <args>

" Define a text object for erb segments (<%= ... %>)
onoremap <buffer> a= :<c-u>call <SID>ErbTextObject('a')<cr>
xnoremap <buffer> a= :<c-u>call <SID>ErbTextObject('a')<cr>
onoremap <buffer> i= :<c-u>call <SID>ErbTextObject('i')<cr>
xnoremap <buffer> i= :<c-u>call <SID>ErbTextObject('i')<cr>
function! s:ErbTextObject(mode)
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

" To be sure it's an erb file
let b:erb_loaded = 1
