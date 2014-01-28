let s:indent_based_languages = ['python', 'coffee', 'haml', 'slim']

" Duplicate lines
nnoremap zj mzyyP`z
nnoremap zk mzyyP`zk

" Duplicate blocks
nnoremap zJ :call <SID>DuplicateBlock('below')<cr>
nnoremap zK :call <SID>DuplicateBlock('above')<cr>

function! s:DuplicateBlock(direction)
  if getline('.') =~ '^\s*$'
    return
  endif

  if index(s:indent_based_languages, &filetype) >= 0
    let block = s:OpenBlock(line('.'), a:direction)
  else
    let block = s:ClosedBlock(line('.'), a:direction)
  endif

  if empty(block)
    return
  endif

  let [start, end] = block
  let lines        = getbufline('%', start, end)

  " The conditions look swapped, but this actually has the indended effect.
  " Remember that the result buffer is the same in both cases, it's the cursor
  " position that matters.
  "
  if a:direction == 'below'
    call append(start - 1, lines + [''])
  else " a:direction == 'above'
    call append(end, [''] + lines)
  endif
endfunction

" A "block" defined by indentation in an indent-based language, without a
" closing tag.
function! s:OpenBlock(start, direction)
  let start_lineno = a:start
  let base_indent  = indent(start_lineno)
  let end_lineno   = start_lineno
  let next_lineno  = nextnonblank(start_lineno + 1)

  while end_lineno < line('$') && indent(next_lineno) > base_indent
    let end_lineno  = next_lineno
    let next_lineno = nextnonblank(end_lineno + 1)
  endwhile

  return [start_lineno, end_lineno]
endfunction

" A "block" defined by a closing tag, "end", curly bracket. Detected by
" another line at the same indent.
function! s:ClosedBlock(start, direction)
  let start_lineno = a:start
  let base_indent  = indent(start_lineno)
  let end_lineno   = nextnonblank(start_lineno + 1)

  while end_lineno < line('$') && indent(end_lineno) != base_indent
    let end_lineno = nextnonblank(end_lineno + 1)
  endwhile

  if indent(start_lineno) != indent(end_lineno)
    " we have an unfinished block, don't duplicate
    return []
  endif

  return [start_lineno, end_lineno]
endfunction
