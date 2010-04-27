set foldmethod=expr
set foldexpr=GtdFoldExpression(v:lnum)
function! GtdFoldExpression(lnum)
  let line = getline(a:lnum)
  if line =~ '== .*'
    return 1
  elseif line =~ '= .*'
    return 'a1'
  elseif line =~ '^\s*$'
    return 's1'
  else
    return '='
  endif
endfunction
