" Explanation:
"
" <div id="foo">Foo, bar, baz</div>
"
" Execute :SplitjoinSplit on the line and:
"
" <div id="foo">
"   Foo, bar, baz
" </div>
command! SplitjoinSplit call s:Split()
function! s:Split()
  if !exists('b:splitjoin_split_data')
    return
  end

  let save_cursor = getpos('.')

  " TODO: not good enough?
  normal! V"zy
  let text = @z

  for [detect, replace] in b:splitjoin_split_data
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
  if !exists('b:splitjoin_join_data')
    return
  end

  let save_cursor = getpos('.')

  for [detect, replace] in b:splitjoin_join_data
    let data = call(detect, [])

    let text = ''

    if data != {}
      let [text, position] = call(replace, [data])
      break
    end
  endfor

  if text != ''
    " then the position variable is defined
    call s:ReplaceArea(text, position)
  endif

  call setpos('.', save_cursor)
endfunction

function! s:ReplaceArea(text, position)
  let from = a:position.from
  let to   = a:position.to

  call cursor(from)
  normal! v
  call cursor(to)

  let @z = a:text
  normal! gv"zp
  normal! gv=
endfunction
