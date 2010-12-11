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

  for [regex, replacement] in s:split_replacements
    if text =~ regex
      if replacement[0] == '*' && exists(replacement)
        " then it's a function
        let Replace = function(strpart(replacement, 1, len(replacement)))
        let text    = call(Replace, [regex, text])
      else
        " it's just a replacement string
        let text = substitute(text, regex, replacement, '')
      endif

      break
    end
  endfor

  if @z != text
    " then there was some modification, paste the new text
    let @z = text
    normal! gv"zp
    normal! gv=
  endif
endfunction

" Replacements need to be ordered by some priority
let s:split_replacements = [
      \ ['\(<.\{-}>\)\(.*\)\(<\/.\{-}>\)', '\1\n\2\n\3'],
      \ ['{\(.*\)}', '*SplitRubyHashes'],
      \ ['\v((,[^,]+\s+\=\>\s+[^,]+)+)\%\>', '*SplitErbOptions'],
      \ ['\v,(([^,]+\s*\=\>\s*[^,]+,?)+)\n', '*SplitRubyOptions'],
      \ ]

" { :one => 'two', :three => 'four' }
"
" becomes:
"
" {
"   :one => 'two',
"   :three => 'four,
" }
function! SplitRubyHashes(regex, text)
  let body     = lib#ExtractRx(a:text, a:regex, '\1')
  let new_body = join(split(body, ','), ",\n")

  return substitute(a:text, a:regex, "{\n".new_body."\n}", '')
endfunction

" link_to 'foo', bar_path, :id => 'foo', :class => 'bar'
"
" becomes:
"
" link_to 'foo', bar_path, {
"   :id => 'foo',
"   :class => 'bar'
" }
function! SplitRubyOptions(regex, text)
  let text = substitute(a:text, a:regex, ', {\1}', '')

  return SplitRubyHashes('{\(.*\)}', text)
endfunction

" <%= link_to 'foo', bar_path, :id => 'foo', :class => 'bar' %>
"
" becomes:
"
" <%= link_to 'foo', bar_path, {
"   :id => 'foo',
"   :class => 'bar'
" } %>
function! SplitErbOptions(regex, text)
  let text = substitute(a:text, a:regex, ', {\1} %>', '')

  return SplitRubyHashes('{\(.*\)}', text)
endfunction

" Simple join command that ignores all whitespace
command Join call s:Join()
function! s:Join()
  normal! j99<kgJ
endfunction
