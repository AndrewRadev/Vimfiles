" While inside a table, returns its start and end column
function! GetCols()
  let save_cursor = getpos('.')

  call search('^\s*\(|\|+\)', 'bcW')
  let start = col('.')
  call search('\(|\|+\)\s*$', 'cW')
  let end = col('.')

  call setpos('.', save_cursor)

  return [start, end]
endfunction

" While inside a table, returns its start and end line
function! GetLines()
  let save_cursor = getpos('.')

  " first, go upwards
  let clineno = line('.')
  let cline   = getline(clineno)

  while clineno > 0 && cline =~ '^\s*|.*|\s*$' || cline =~ '^\s*+-\*+\s*$'
    let clineno = clineno - 1
    let cline = getline(clineno)
  endwhile

  let start = clineno

  call setpos('.', save_cursor)
  let clineno = line('.')
  let cline   = getline(clineno)
  let llineno = line('$')

  while clineno < llineno && cline =~ '^\s*|.*|\s*$' || cline =~ '^\s*+-\*+\s*$'
    let clineno = clineno + 1
    let cline   = getline(clineno)
  endwhile

  let end = clineno

  call setpos('.', save_cursor)

  return [start, end]
endfunction
