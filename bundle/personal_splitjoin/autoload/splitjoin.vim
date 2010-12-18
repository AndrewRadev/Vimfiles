" Trimming functions. Should be obvious.
function! splitjoin#Ltrim(s)
	return substitute(a:s, '^\s\+', '', '')
endfunction
function! splitjoin#Rtrim(s)
	return substitute(a:s, '\s\+$', '', '')
endfunction
function! splitjoin#Trim(s)
  return splitjoin#Rtrim(splitjoin#Ltrim(a:s))
endfunction

" Extract a regex match from a string.
function! splitjoin#ExtractRx(expr, pat, sub)
  let rx = a:pat

  if stridx(a:pat, '^') != 0
    let rx = '^.*'.rx
  endif

  if strridx(a:pat, '$') + 1 != strlen(a:pat)
    let rx = rx.'.*$'
  endif

  return substitute(a:expr, rx, a:sub, '')
endfunction
