" Explanation:
"
" <div id="foo">Foo, bar, baz</div>
"
" Mark it in visual, execute :Split and:
"
" <div id="foo">
"   Foo, bar, baz
" </div>
command! -range Split call s:Split()
function! s:Split()
  normal! gv"zy
  let text = @z

  " let tag_regex = '\s*' . '\(<.\{-}>\)' . '\(.*\)' . '\(<\/.\{-}>\)'
  " if text =~ tag_regex
  "   let text = substitute(text, tag_regex, '\1\n\2\n\3', '')
  " endif

  for [regex, replacement] in items(s:split_replacements)
    if text =~ regex
      let text = substitute(text, regex, replacement, '')
      break
    end
  endfor

  let @z = text
  normal! gv"zp
  normal! gv=
endfunction

let s:split_replacements = {
      \ '\(<.\{-}>\)\(.*\)\(<\/.\{-}>\)': '\1\n\2\n\3',
      \ '{\(.*\)}': '\="{\n".join(split(submatch(1), ","), ",\n")."\n}"',
      \ }
