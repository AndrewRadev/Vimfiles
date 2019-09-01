setlocal nowrap
" setlocal cursorline

nnoremap <buffer> <cr> <cr>

nnoremap <buffer> <c-w>< :silent colder<cr>
nnoremap <buffer> <c-w>> :silent cnewer<cr>

nnoremap <buffer> ,w :WritableSearchFromQuickfix<cr>
nnoremap <buffer> <c-p> :QuickpeekToggle<cr>

let b:whitespaste_disable = 1
nnoremap <buffer> p :call <SID>PasteBacktrace(v:register)<cr>

if !exists('*s:PasteBacktrace')
  function s:PasteBacktrace(register)
    let saved_errorformat = &errorformat
    let register_contents = getreg(a:register)

    if register_contents =~ '^rspec'
      set errorformat=rspec\ %f:%l\ #\ %m
      let rspec_errors = register_contents
      cexpr rspec_errors
    else
      echohl WarningMsg | echo "Don't know how to paste:\n" . register_contents | echohl NONE
    endif

    let &errorformat = saved_errorformat
  endfunction
endif

command! -buffer YankFilenames call s:YankFilenames()
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
