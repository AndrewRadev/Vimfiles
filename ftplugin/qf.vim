setlocal nowrap

nnoremap <buffer> <cr> <cr>

nnoremap <buffer> <c-w>< :silent colder<cr>
nnoremap <buffer> <c-w>> :silent cnewer<cr>

nnoremap <buffer> ,w :WritableSearchFromQuickfix<cr>

command! YankFilenames call s:YankFilenames()
function! s:YankFilenames()
  let filenames = map(getqflist(), {_, entry -> bufname(entry.bufnr)})
  call sort(filenames)
  call uniq(filenames)
  let filename_string = join(filenames, ' ')

  let @" = filename_string
  if &clipboard =~ '\<unnamed\>'
    let @* = filename_string
  endif
  if &clipboard =~ '\<unnamedplus\>'
    let @+ = filename_string
  endif
endfunction
