nnoremap <Leader>% :call <SID>MarkMatches()<cr>
function! s:MarkMatches()
  call clearmatches()

  let b:match_positions = []

  " Get the first position to highlight
  let pos = lib#HiCword('Search')
  while index(b:match_positions, pos) == -1
    call add(b:match_positions, pos)
    normal %

    " Get the next position
    let pos = lib#HiCword('Search')
  endwhile
endfunction

command Noh noh | call clearmatches()
