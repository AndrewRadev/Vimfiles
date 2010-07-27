function! rspec_output#IncludeExpression(fname)
  let lineno = lib#ExtractRx(getline('.'), '\f\+\(:\d\+\):', '\1')
  exe 'e '.a:fname
  exe lineno
endfunction
