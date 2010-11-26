" Explanation:
"
" <div id="foo">Foo, bar, baz</div>
"
" Execute :Split on the line and:
"
" <div id="foo">
"   Foo, bar, baz
" </div>
command! Split call s:Split()
function! s:Split()
  normal! V"zy
  let text = @z

  " let tag_regex = '\s*' . '\(<.\{-}>\)' . '\(.*\)' . '\(<\/.\{-}>\)'
  " if text =~ tag_regex
  "   let text = substitute(text, tag_regex, '\1\n\2\n\3', '')
  " endif

  for [regex, replacement] in items(s:split_replacements)
    if text =~ regex
      if replacement[0] == '*' && exists(replacement) " then it's a function
        let Replace = function(strpart(replacement, 1, len(replacement)))
        let text    = call(Replace, [regex, text])
      else " it's just a replacement string
        let text = substitute(text, regex, replacement, '')
      endif

      break
    end
  endfor

  let @z = text
  normal! gv"zp
  normal! gv=
endfunction

let s:split_replacements = {
      \ '\(<.\{-}>\)\(.*\)\(<\/.\{-}>\)': '\1\n\2\n\3',
      \ '{\(.*\)}': '*SplitRubyHashes',
      \ }

function! SplitRubyHashes(regex, text)
  let body     = lib#ExtractRx(a:text, a:regex, '\1')
  let new_body = join(split(body, ','), ",\n")

  return substitute(a:text, a:regex, "{\n".new_body."\n}", '')
endfunction

command Join call s:Join()
function! s:Join()
  normal! j99<kgJ
endfunction
