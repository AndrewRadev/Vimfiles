" Simpler tag searches:
command! -nargs=1 -complete=customlist,s:CompleteFunction Function TTags f <args>
command! -nargs=1 -complete=customlist,s:CompleteClass    Class    TTags c <args>
function! s:CompleteFunction(A, L, P)
  return sort(map(filter(taglist('^'.a:A), 'v:val["kind"] == "f"'), 'v:val["name"]'))
endfunction
function! s:CompleteClass(A, L, P)
  return sort(map(filter(taglist('^'.a:A), 'v:val["kind"] == "c"'), 'v:val["name"]'))
endfunction

" Clear up garbage:
command! CleanGarbage %s/\s\+$//e
