command! -nargs=* -buffer WhatIf call s:WhatIf(<q-args>)
function! s:WhatIf(label)
  let label = a:label

  if search('^\s*\zsif ', 'Wbc') <= 0
    return
  endif

  let debug_index = 1
  let saved_register_text = getreg('z', 1)
  let saved_register_type = getregtype('z')

  while getline('.') !~ '^\s*end\>'
    let if_lineno = line('.')
    let if_line = lib#Trim(getline('.'))

    while indent(line('.') + 1) > indent(if_lineno) + shiftwidth()
          \ && getline(line('.') + 1) !~ '^\s*\%(else\|elsif\)\>'
      " it's probably a continuation, move downwards
      normal! j
    endwhile

    if len(if_line) <= 23
      let line_description = if_line
    else
      let line_description = strpart(if_line, 0, 20)."..."
    endif
    let line_description = escape(line_description, '"')

    if label != ''
      let @z = "puts \"Debug (" . label . ") " . debug_index . ': ' . line_description . '"'
    else
      let @z = "puts \"Debug " . debug_index . ': ' . line_description . '"'
    endif

    put z
    normal! ==
    let debug_index += 1

    exe if_lineno
    normal %
  endwhile

  call setreg('z', saved_register_text, saved_register_type)
endfunction
