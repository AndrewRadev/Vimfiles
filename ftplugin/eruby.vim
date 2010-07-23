let b:surround_{char2nr('-')} = "<% \r %>"
let b:surround_{char2nr('=')} = "<%= \r %>"
" surround area with <% <foo> (...) do %> <% end %>
let b:surround_{char2nr('I')} = "<% if \1if: \1 %> \r <% end %>"
let b:surround_{char2nr('W')} = "<% while \1while: \1 do %> \r <% end %>"
let b:surround_{char2nr('E')} = "<% \1collection: \1.each do |\2item: \2| %> \r <% end %>"

RunCommand !erb % <args>

" To be sure it's an erb file
let b:erb_loaded = 1
