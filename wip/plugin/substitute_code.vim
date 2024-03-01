finish

command! -nargs=1 -range Scode call s:Scode(<q-args>, <line1>, <line2>)

" Input should be something like /<pattern>/<replacement>/<flags>
function! s:Scode(input, line1, line2) abort
  if len(a:input) == 0
    return
  endif

  " Extract the pattern so we can search for it ourselves
  let delimiter = a:input[0]
  let pattern = matchstr(a:input, '^' .. delimiter .. '\zs.\{-}[^\\]\ze' .. delimiter)

  " We prepare a skip pattern that will skip anything that is NOT a comment.
  " We'll find the coordinates and ignore them in the real substitution:
  let skip_pattern    = '\%(Comment\)'
  let skip_expression = "synIDattr(synID(line('.'),col('.'),1),'name') !~ '".skip_pattern."'"

  let saved_view = winsaveview()

  try
    let ignored_positions = []

    " start at the last char in the file and wrap for the
    " first search to find match at start of file
    normal G$

    let flags = "w"
    " default values:
    let stopline = 0
    let timeout = 0

    while search(pattern, flags, stopline, timeout, skip_expression) > 0
      call add(ignored_positions, [line('.'), col('.')])
      let flags = "W"
    endwhile

    " compose a pattern that will avoid matching at string/comment positions:
    let ignore_pattern = join(map(ignored_positions, { _, pos -> '\%(\%'..pos[0]..'l\%'..pos[1]..'c\)\@!' }), '')

    " insert pattern after initial delimiter:
    let range = a:line1 .. ',' .. a:line2
    let substitute_command =
        \ range .. 's' ..
        \ delimiter ..
        \ escape(ignore_pattern, delimiter) ..
        \ strpart(a:input, 1)

    exe substitute_command
  finally
    call winrestview(saved_view)
  endtry
endfunction
