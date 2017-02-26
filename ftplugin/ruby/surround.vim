" surround area with <foo> (...) { }
if !exists('b:erb_loaded')
  let b:surround_{char2nr('i')} = "if \1if: \1 \r end"
  let b:surround_{char2nr('u')} = "unless \1unless: \1 \r end"
  let b:surround_{char2nr('w')} = "while \1while: \1 do \r end"
  let b:surround_{char2nr('e')} = "\1collection: \1.each do |\2item: \2| \r end"
  let b:surround_{char2nr('m')} = "module \r end"
  let b:surround_{char2nr('d')} = "do\n \r end"
endif

let b:surround_{char2nr('#')} = "#{\r}"
let b:surround_indent = 1
