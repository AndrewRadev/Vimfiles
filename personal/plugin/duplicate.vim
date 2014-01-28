" Duplicate lines
nnoremap zj mzyyP`z
nnoremap zk mzyyP`zk

" Duplicate blocks
nnoremap zJ :call <SID>DuplicateBlock('below')<cr>
nnoremap zK :call <SID>DuplicateBlock('above')<cr>

function! s:DuplicateBlock(direction)
  if index(['python', 'coffee', 'haml', 'slim'], &filetype) >= 0
    let block = s:OpenBlock(a:direction)
  else
    let block = s:ClosedBlock(a:direction)
  endif

  let [start, end, lines] = block

  if a:direction == 'below'
    call append(start - 1, lines + [''])
  else " a:direction == 'above'
    call append(end, [''] + lines)
  endif
endfunction

" A "block" defined by indentation in an indent-based language, without a
" closing tag
function! s:OpenBlock(direction)
  let base_indent  = indent('.')
  let start_lineno = line('.')
  let end_lineno   = start_lineno
  let next_lineno  = nextnonblank(start_lineno + 1)

  while end_lineno < line('$') && indent(next_lineno) > base_indent
    let end_lineno  = next_lineno
    let next_lineno = nextnonblank(end_lineno + 1)
  endwhile

  let lines = getbufline('%', start_lineno, end_lineno)

  return [start_lineno, end_lineno, lines]
endfunction

" A "block" defined by a closing tag, "end", curly bracket. Detected by
" another line at the same indent.
function! s:ClosedBlock(direction)
  let start_lineno = line('.')
  let start_line   = getline(start_lineno)

  if start_line =~ '^\s*$'
    return
  endif

  let indent     = matchstr(start_line, '^\s*\ze\S')
  let end_lineno = nextnonblank(start_lineno + 1)
  let end_line   = getline(end_lineno)

  while end_lineno < line('$') && end_line !~ '^'.indent.'\S'
    let end_lineno = nextnonblank(end_lineno + 1)
    let end_line   = getline(end_lineno)
  endwhile

  let lines = getbufline('%', start_lineno, end_lineno)

  return [start_lineno, end_lineno, lines]
endfunction
