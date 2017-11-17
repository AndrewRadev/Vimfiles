command! -nargs=* Blink call s:Blink(<q-args>)
function! s:Blink(pattern)
  let b:blink_color = "blue"
  let b:blink_pattern = a:pattern

  augroup Blink
    autocmd!

    if b:blink_pattern != ''
      autocmd CursorMoved <buffer> call s:ToggleBlink(b:blink_pattern)
    endif
  augroup END
endfunction
function! s:ToggleBlink(pattern)
  exe 'syn match Blinking /'.escape(a:pattern, '/').'/'

  if b:blink_color == "red"
    highlight Blinking ctermfg=blue
    let b:blink_color = "blue"
  else
    highlight Blinking ctermfg=red
    let b:blink_color = "red"
  endif
endfunction
