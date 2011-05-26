function! RubyFold()
  let b:foldtexts = {}
  setlocal foldtext=RubyFoldText()

  let save_cursor = getpos('.')

  " remove all folds for now
  set foldmethod=manual
  normal! zE
  normal! gg

  " fold functions and modules
  if &ft =~ 'rspec'
    call s:FoldAreas('it .* do',       0, line('$'))
    call s:FoldAreas('context .* do',  0, line('$'))
    call s:FoldAreas('describe .* do', 0, line('$'))
  else
    call s:FoldAreas('\<def\>',    0, line('$'))
    call s:FoldAreas('\<module\>', 0, line('$'))
  endif

  " fold public, private, protected scopes
  let scope_regex = '\v^\s*(public|private|protected)\s*$'
  while 1
    let scope_line = search(scope_regex, 'W')
    if scope_line <= 0
      break
    endif

    let scope_name = lib#ExtractRx(getline('.'), scope_regex, '\1')

    let end_line = s:ConsumeWhitespace(scope_line)

    let b:foldtexts[scope_line] = '           | '.scope_name.' |           '
    exec scope_line.','.end_line.'fold'
  endwhile

  normal! zM
endfunction

function! RubyFoldText()
  let line = v:foldstart

  if has_key(b:foldtexts, line)
    return b:foldtexts[line]
  else
    return foldtext()
  endif
endfunction

function! s:FoldAreas(pattern, from, to)
  let from = a:from
  let to   = a:to

  let save_cursor = getpos('.')

  call cursor(from, 0)

  while 1
    let start_line = search(a:pattern, 'Wc', to)
    if start_line <= 0
      break
    endif

    " ignore a:pattern in comments
    if getline(start_line) =~ '#.*' . a:pattern
      normal! j
      continue
    endif

    let ws = lib#ExtractRx(getline('.'), '^\(\s*\)', '\1')

    let end_line = search('^'.ws.'end', 'W', to)
    if end_line <= 0
      break
    endif

    let end_line = s:ConsumeWhitespace(end_line)

    exec start_line.','.end_line.'fold'
    normal! zo

    if start_line >= from && end_line <= to
      call s:FoldAreas(a:pattern, start_line + 1, end_line - 1)
    endif
  endwhile

  call setpos('.', save_cursor)
endfunction

function! s:ConsumeWhitespace(line)
  let line      = a:line
  let last_line = line('$')

  while getline(line + 1) =~ '^\s*$' && line < last_line
    let line = line + 1
    normal! j
  endwhile

  return line
endfunction
