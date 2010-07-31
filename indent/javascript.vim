if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

setlocal indentexpr=javascript#GetIndent()
setlocal indentkeys={,},o,O

"setlocal debug=msg
