setlocal foldmethod=indent
setlocal nofoldenable

call SetupPreview('js', 'coffee -p %s')
RunCommand Preview

nnoremap dh :call <SID>DeleteAndDedent()<cr>
function! s:DeleteAndDedent()
  let base_indent  = indent('.')
  let current_line = line('.')
  let next_line    = nextnonblank(current_line + 1)

  while current_line < line('$') && indent(next_line) > base_indent
    let current_line = next_line
    let next_line    = nextnonblank(current_line + 1)
  endwhile

  let saved_cursor = getpos('.')
  silent exe line('.').','.current_line.'<'
  call setpos('.', saved_cursor)

  normal! dd
endfunction
