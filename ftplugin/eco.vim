let b:surround_{char2nr('-')} = "<% \r %>"
let b:surround_{char2nr('=')} = "<%= \r %>"
" surround area with <% <foo> (...) do %> <% end %>
let b:surround_{char2nr('I')} = "<% if \1<% if: \1: %> \r <% end %>"
let b:surround_{char2nr('U')} = "<% unless \1<% unless: \1: %> \r <% end %>"

let b:surround_{char2nr('#')} = "#{\r}"

let b:switch_definitions =
      \ [
      \   {
      \     '<%=\(.\{-}\)%>': '<%-\1%>',
      \     '<%-\(.\{-}\)%>': '<%=\1%>',
      \   },
      \   {
      \     'if true or (\(.*\)):':          'if false and (\1):',
      \     'if false and (\(.*\)):':        'if \1:',
      \     'if \%(true\|false\)\@!\(.*\):': 'if true or (\1):',
      \   },
      \ ]

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

let b:splitjoin_split_callbacks = ['sj#html#SplitTags']
let b:splitjoin_join_callbacks  = ['sj#html#JoinTags']

autocmd Syntax * hi link coffeeSpecialVar Identifier
autocmd Syntax * hi link ecoDelimiter PreProc
