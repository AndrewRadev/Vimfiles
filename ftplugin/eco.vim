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

let b:splitjoin_split_callbacks = ['sj#html#SplitTags']
let b:splitjoin_join_callbacks  = ['sj#html#JoinTags']

augroup eco
  autocmd!

  autocmd Syntax * hi link coffeeSpecialVar Identifier
  autocmd Syntax * hi link ecoDelimiter PreProc
augroup END
