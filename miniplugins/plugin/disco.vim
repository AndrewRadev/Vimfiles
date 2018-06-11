command! -nargs=* Disco call s:Disco(<q-args>)
function! s:Disco(pattern)
  let b:disco_color = "blue"
  let b:disco_pattern = a:pattern

  augroup Disco
    autocmd!

    if b:disco_pattern != ''
      autocmd CursorMoved <buffer> call s:ToggleDisco(b:disco_pattern)
    endif
  augroup END
endfunction
function! s:ToggleDisco(pattern)
  exe 'syn match Disco /'.escape(a:pattern, '/').'/'

  if b:disco_color == "red"
    highlight Disco ctermfg=blue cterm=bold
    let b:disco_color = "blue"
  else
    highlight Disco ctermfg=red cterm=bold
    let b:disco_color = "red"
  endif
endfunction
