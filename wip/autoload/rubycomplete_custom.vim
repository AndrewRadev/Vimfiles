" Experimental omnifunction
function! rubycomplete_custom#Complete(findstart, base)
  if a:findstart
    return s:Findstart()
  else
    return s:GenerateCompletion(a:base)
  endif
endfunction

function! s:Findstart()
  if search('\k\+\%#', 'bc', line('.')) <= 0
    return -1
  else
    return col('.') - 1
  endif
endfunction

function! s:GenerateCompletion(base)
  let tags = taglist('^'.a:base)
  return map(tags, 'v:val.name')
endfunction
