function! RubyFold()
  let b:foldtexts = {}
  setlocal foldtext=RubyFoldText()

  let save_cursor = getpos('.')

  " remove all folds for now
  set foldmethod=manual
  normal! zE

  " fold functions
  normal! gg

  call s:FoldAreas('\<def\>')
  " call s:FoldAreas('\<module\>')

  " fold public, private, protected scopes
  normal! gg
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

  call cursor(save_cursor)
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

function! s:FoldAreas(pattern)
  while 1
    let start_line = search(a:pattern, 'W')
    if start_line <= 0
      break
    endif

    " ignore a:pattern in comments
    if getline(start_line) =~ '#.*' . a:pattern
      normal! j
      continue
    endif

    let ws = lib#ExtractRx(getline('.'), '^\(\s*\)', '\1')

    let end_line = search('^'.ws.'end', 'W')
    if end_line <= 0
      break
    endif

    let end_line = s:ConsumeWhitespace(end_line)

    exec start_line.','.end_line.'fold'
    normal! zo
  endwhile
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
