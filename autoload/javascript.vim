function! javascript#GetIndent()
  " get previous line:
  let plineno = prevnonblank(v:lnum - 1)
  let pline   = getline(plineno)
  " get current line:
  let line    = getline(v:lnum)

  if pline =~ '{\s*$'
    return indent(plineno) + &shiftwidth
  elseif line =~ '\s*}'
    call search('}', 'bcW')
    let match_lineno = searchpair('{', '', '}', 'bW', 'javascript#NotInCode()')
    return indent(match_lineno)
  end

  return indent(plineno)
endfunction

function! javascript#NotInCode()
  let [_buf, line, col, _off] = getpos('.')
  let syntax_name = synIDattr(synID(line, col, 1), 'name')
  return (syntax_name == 'string'
        \ || syntax_name == 'javaScriptLineComment'
        \ || syntax_name == 'javaScriptComment'
        \ )
endfunction
