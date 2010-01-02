" Simpler tag searches:
command! -nargs=1 -complete=customlist,s:CompleteFunction Function TTags f <args>
command! -nargs=1 -complete=customlist,s:CompleteClass    Class    TTags c <args>
function! s:CompleteFunction(A, L, P)
  return sort(map(filter(taglist('^'.a:A), 'v:val["kind"] == "f"'), 'v:val["name"]'))
endfunction
function! s:CompleteClass(A, L, P)
  return sort(map(filter(taglist('^'.a:A), 'v:val["kind"] == "c"'), 'v:val["name"]'))
endfunction

" Change fonts on the GUI:
if has("win32")
  command! FontDejaVu   set guifont=DejaVu_Sans_Mono:h12
  command! FontTerminus set guifont=Terminus:h15
else
  command! FontAndale   set guifont=Andale\ Mono\ 13
  command! FontTerminus set guifont=Terminus\ 14
endif

" Clear up garbage:
command! CleanGarbage %s/\s\+$//e

" Fix dos-style line endings:
command! FixEol %s/$//e
