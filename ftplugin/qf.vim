setlocal nowrap

syntax match quickfixComment '^||.*$'
hi link quickfixComment Comment

nnoremap <buffer> <cr> <cr>

xnoremap <buffer> d :DeleteLines<cr>
nnoremap <buffer> d :set opfunc=<SID>DeleteMotion<cr>g@
nnoremap <buffer> dd V:DeleteLines<cr>

nnoremap <buffer> u     :colder<cr>
nnoremap <buffer> <c-r> :cnewer<cr>

nnoremap <buffer> <c-w>< :colder<cr>
nnoremap <buffer> <c-w>> :cnewer<cr>

" open
nnoremap <buffer> o <cr>
" open in a tab
nnoremap <buffer> t <c-w><cr><c-w>T
" open in a tab without switching to it
nnoremap <buffer> T <c-w><cr><c-w>TgT<c-w>j
" open in a horizontal split
nnoremap <buffer> i <c-w><cr><c-w>K
" open in a vertical split
nnoremap <buffer> S <C-W><CR><C-W>H<C-W>b<C-W>J<C-W>t

if !exists(':DeleteLines')
  command! -buffer -nargs=1 -bang Delete call s:Delete(<f-args>, '<bang>')
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
    call setpos('.', saved_cursor)
    echo
  endfunction

  function! s:DeleteMotion(_type)
    call s:DeleteLines(line("'["), line("']"))
  endfunction

  command! -buffer -range DeleteLines call s:DeleteLines(<line1>, <line2>)
  function! s:DeleteLines(start, end)
    let saved_cursor = getpos('.')
    let start        = a:start - 1
    let end          = a:end - 1

    let qflist  = getqflist()
    call remove(qflist, start, end)
    call setqflist(qflist)

    call setpos('.', saved_cursor)
    echo
  endfunction

  command! -buffer -range Only call s:Only(<line1>, <line2>)
  function! s:Only(start, end)
    let saved_cursor = getpos('.')
    let start        = a:start - 1
    let end          = a:end - 1

    let qflist = getqflist()
    let last_index = len(qflist) - 1
    let new_qflist = qflist[start:end]

    call setqflist(new_qflist)
    call setpos('.', saved_cursor)
    echo
  endfunction

  function! s:EntryMatches(entry, pattern)
    return (a:entry.text =~ a:pattern) || (bufname(a:entry.bufnr) =~ a:pattern)
  endfunction
endif
