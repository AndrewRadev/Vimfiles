function! RubyFold()
  let b:foldtexts = {}
  setlocal foldtext=RubyFoldText()

  let save_cursor = getpos('.')

  " remove all folds for now
  set foldmethod=manual
  normal! zE

  " fold functions
  normal! gg
  while 1
    let def_line = search('\<def\>', 'W')
    if def_line <= 0
      break
    endif

    let ws = lib#ExtractRx(getline('.'), '^\(\s*\)', '\1')

    let end_line = search('^'.ws.'end', 'W')
    if end_line <= 0
      break
    endif

    while getline(line('.') + 1) =~ '^\s*$'
      let end_line = end_line + 1
      normal! j
    endwhile

    exec def_line.','.end_line.'fold'
  endwhile

  " fold public, private, protected scopes
  normal! gg
  let scope_regex = '\v^\s*(public|private|protected)\s*$'
  while 1
    let scope_line = search(scope_regex, 'W')
    if scope_line <= 0
      break
    endif

    let scope_name = lib#ExtractRx(getline('.'), scope_regex, '\1')

    let end_line = scope_line

    while getline(line('.') + 1) =~ '^\s*$'
      let end_line = end_line + 1
      normal! j
    endwhile

    let b:foldtexts[scope_line] = '           | '.scope_name.' |           '
    exec scope_line.','.end_line.'fold'
  endwhile

  call cursor(save_cursor)
endfunction

function! RubyFoldText()
  let line = v:foldstart

  if has_key(b:foldtexts, line)
    return b:foldtexts[line]
  else
    return foldtext()
  endif
endfunction
