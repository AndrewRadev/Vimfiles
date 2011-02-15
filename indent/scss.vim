if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal autoindent sw=2 et
setlocal indentexpr=GetScssIndent()
setlocal indentkeys=o,O,*<Return>,<:>,!^F

" Only define the function once.
if exists("*GetScssIndent")
  finish
endif

function! GetScssIndent()
  " get previous line:
  let plineno = prevnonblank(v:lnum - 1)
  let pline   = getline(plineno)
  " get current line:
  let line    = getline(v:lnum)

  if pline =~ '{\s*$'
    return indent(plineno) + &shiftwidth
  elseif line =~ '}\s*$'
    call search('}', 'bcW')
    let match_lineno = searchpair('{', '', '}', 'bW', 'WithinScssComment')
    return indent(match_lineno)
  end

  return indent(plineno)
endfunction

function! WithinScssComment()
  let [_buf, line, col, _off] = getpos('.')
  let syntax_name = synIDattr(synID(line, col, 1), 'name')
  return (syntax_name == 'scssComment')
endfunction
