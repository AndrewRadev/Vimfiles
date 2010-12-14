" Explanation:
"
" <div id="foo">Foo, bar, baz</div>
"
" Execute :Split on the line and:
"
" <div id="foo">
"   Foo, bar, baz
" </div>
command! SplitjoinSplit call s:Split()
function! s:Split()
  if !exists('b:splitjoin_data')
    return
  end

  let save_cursor = getpos('.')

  " TODO: not good enough?
  normal! V"zy
  let text = @z

  for [detect, replace] in b:splitjoin_data
    let data = call(detect, [])

    if data != {}
      let text = call(replace, [data])
      break
    end
  endfor

  if @z != text
    " then there was some modification, paste the new text
    let @z = text
    normal! gv"zp
    normal! gv=
  endif

  call setpos('.', save_cursor)
endfunction

" Simple join command that ignores all whitespace
command SplitjoinJoin call s:Join()
function! s:Join()
  let save_cursor = getpos('.')

  normal! j
  s/^\s*//
  exec "normal! i\<bs>"

  call setpos('.', save_cursor)
endfunction
