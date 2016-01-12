setlocal nowrap

syntax match quickfixComment '^||.*$'
hi link quickfixComment Comment

xnoremap <buffer> d  :DeleteLines<cr>
nnoremap <buffer> dd :DeleteLines<cr>
nnoremap <buffer> u  :UndoDelete<cr>

" open
nnoremap <buffer> o <cr>
" open in a tab
nnoremap <buffer> t <c-w><cr><c-w>T
" open in a tab without switching to it
nnoremap <buffer> T <c-w><cr><c-w>TgT<c-w>j
" open in a horizontal split
nnoremap <buffer> i <c-w><cr><c-w>K
" open in a vertical split
nnoremap <buffer> s <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t

if !exists(':DeleteLines')
  let b:deletion_stack = []

  command! -nargs=1 -bang Delete call s:Delete(<f-args>, '<bang>')
  function! s:Delete(pattern, bang)
    let saved_cursor = getpos('.')
    let deleted      = []

    let new_qflist = []
    for entry in getqflist()
      if (!s:EntryMatches(entry, a:pattern) && a:bang == '') || (s:EntryMatches(entry, a:pattern) && a:bang == '!')
        call add(new_qflist, entry)
      else
        call add(deleted, entry)
      endif
    endfor

    call setqflist(new_qflist)
    if !empty(deleted)
      call insert(b:deletion_stack, [0, deleted], 0)
    endif

    call setpos('.', saved_cursor)
    echo
  endfunction

  command! -range -buffer DeleteLines call s:DeleteLines(<line1>, <line2>)
  function! s:DeleteLines(start, end)
    let saved_cursor = getpos('.')
    let start        = a:start - 1
    let end          = a:end - 1

    let qflist  = getqflist()
    let deleted = remove(qflist, start, end)
    call insert(b:deletion_stack, [start, deleted], 0)

    call setqflist(qflist)
    call setpos('.', saved_cursor)
    echo
  endfunction

  command! -buffer UndoDelete call s:UndoDelete()
  function! s:UndoDelete()
    if empty(b:deletion_stack)
      return
    endif

    let saved_cursor = getpos('.')
    let qflist       = getqflist()

    let [index, deleted] = remove(b:deletion_stack, 0)
    for line in deleted
      call insert(qflist, line, index)
      let index = index + 1
    endfor

    call setqflist(qflist)
    call setpos('.', saved_cursor)
    echo
  endfunction

  function! s:EntryMatches(entry, pattern)
    return (a:entry.text =~ a:pattern) || (bufname(a:entry.bufnr) =~ a:pattern)
  endfunction
endif
