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

    " pattern like `rspec filename[<context number>:<test number>]`. No way to
    " parse it directly, we put the file in the list and stick to line 1
    let context_pattern = 'rspec ''\(\f\+\)\(\[\%(\d\|:\)\+\]\)'' #'

    if register_contents =~ '^rspec'
      let rspec_errors = []
      for line in split(register_contents, "\n")
        if line =~ context_pattern
          let line = substitute(line, context_pattern, 'rspec \1:1 # \2', '')
        endif

        call add(rspec_errors, line)
      endfor

      call uniq(rspec_errors)

      set errorformat=rspec\ %f:%l\ #\ %m
      cexpr join(rspec_errors, "\n")
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
