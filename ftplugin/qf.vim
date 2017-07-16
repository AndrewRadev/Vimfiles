setlocal nowrap

nnoremap <buffer> <cr> <cr>

nnoremap <buffer> <c-w>< :silent colder<cr>
nnoremap <buffer> <c-w>> :silent cnewer<cr>

nnoremap <buffer> ,w :WritableSearchFromQuickfix<cr>

let b:whitespaste_disable = 1
nnoremap <buffer> p :call <SID>PasteBacktrace()<cr>

if !exists('*s:PasteBacktrace')
  function s:PasteBacktrace()
    let saved_errorformat = &errorformat

    if @" =~ '^rspec'
      set errorformat=rspec\ %f:%l\ #\ %m
      let rspec_errors = @"
      cexpr rspec_errors
    else
      echohl WarningMsg | echo "Don't know how to paste:\n" . @" | echohl NONE
    endif

    let &errorformat = saved_errorformat
  endfunction
endif

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
