command! -range Split call s:Split()
function! s:Split()
  normal! gv"zy
  let text = @z

  let tag_regex = '\s*' . '\(<.\{-}>\)' . '\(.*\)' . '\(<\/.\{-}>\)'
  if text =~ tag_regex
    let text = substitute(text, tag_regex, '\1\n\2\n\3', '')
  endif

  let @z = text
  normal! gv"zp
  normal! gv=
endfunction
