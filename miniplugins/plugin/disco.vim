command! -nargs=* Disco call s:Disco(<q-args>)
function! s:Disco(pattern)
  let b:disco_pattern = a:pattern
  let b:disco_match_ids = get(b:, 'disco_match_ids', [])

  if b:disco_pattern == ''
    " Stop highlighting
    for match_id in b:disco_match_ids
      call matchdelete(match_id)
    endfor
    let b:disco_match_ids = []
  else
    " Start highlighting
    if !exists('b:disco_color')
      let b:disco_color = "blue"
      call s:DiscoBlue()
    endif

    call add(b:disco_match_ids, matchadd('Disco', a:pattern))
  end

  augroup Disco
    autocmd!

    if b:disco_pattern != ''
      autocmd CursorMoved <buffer> call s:ToggleDisco(b:disco_pattern)
    endif
  augroup END
endfunction

function! s:ToggleDisco(pattern)
  if b:disco_color == "red"
    call s:DiscoRed()
    let b:disco_color = "blue"
  else
    call s:DiscoBlue()
    let b:disco_color = "red"
  endif
endfunction

function! s:DiscoBlue()
  highlight Disco cterm=bold ctermfg=blue guifg=blue gui=bold
endfunction

function! s:DiscoRed()
  highlight Disco cterm=bold ctermfg=red guifg=red gui=bold
endfunction
