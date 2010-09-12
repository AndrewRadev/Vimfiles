function! hl_matchit#HiArea(syn, from, to)
  let line_to   = a:to[0] + 1
  let col_to    = a:to[1] + 1
  let line_from = a:from[0] - 1
  let col_from  = a:from[1] - 1

  let line_from = line_from >= 0 ? line_from : 0
  let col_from  = col_from  >= 0 ? col_from  : 0

  let pattern = ''
  let pattern .= '\%>'.line_from.'l'
  let pattern .= '\%<'.line_to.'l'
  let pattern .= '\%>'.col_from.'c'
  let pattern .= '\%<'.col_to.'c'

  call matchadd(a:syn, pattern)
endfunction

function! hl_matchit#HiCword(syn)
  normal! "zyiw
  let from = searchpos(@z, 'bWcn')
  let to   = searchpos(@z, 'eWcn')

  call hl_matchit#HiArea(a:syn, from, to)

  return [from, to]
endfunction

function! hl_matchit#MarkMatches(syn)
  call clearmatches()
  let save_cursor = getpos('.')

  let b:match_positions = []

  " Get the first position to highlight
  let pos = hl_matchit#HiCword(a:syn)
  while index(b:match_positions, pos) == -1
    call add(b:match_positions, pos)
    normal %

    " Get the next position
    let pos = hl_matchit#HiCword(a:syn)
  endwhile

  call setpos('.', save_cursor)
endfunction
