setlocal nowrap

nnoremap <buffer> <cr> <cr>

nnoremap <buffer> <c-w>< :silent colder<cr>
nnoremap <buffer> <c-w>> :silent cnewer<cr>

nnoremap <buffer> ,w :WritableSearchFromQuickfix<cr>

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

command! -buffer PreviewPopup call s:PreviewPopup()
function! s:PreviewPopup()
  let b:preview_popup = -1
  let b:preview_line = -1

  augroup preview_popup
    autocmd!
    autocmd CursorMoved * call s:UpdatePreviewPopup()
    autocmd WinLeave <buffer> call s:ClearPreviewPopups()
  augroup END
endfunction

function! s:ClearPreviewPopups()
  call popup_close(b:preview_popup)
  unlet b:preview_popup
  unlet b:preview_line

  augroup preview_popup
    autocmd!
  augroup END
endfunction

function! s:UpdatePreviewPopup()
  if line('.') == b:preview_line
    return
  endif
  let b:preview_line = line('.')

  call popup_close(b:preview_popup)

  let qf_entry = getqflist()[line('.') - 1]

  let wininfo = {}
  for item in getwininfo()
    if item.winnr == winnr()
      let wininfo = item
      break
    endif
  endfor
  if wininfo == {}
    return
  endif

  let b:preview_popup = popup_create(qf_entry.bufnr, {
        \ 'maxheight': 7,
        \ 'minwidth': wininfo.width - 3,
        \ 'maxwidth': wininfo.width - 3,
        \ 'pos': 'botleft',
        \ 'col': wininfo.wincol,
        \ 'line': wininfo.winrow - 2,
        \ 'firstline': max([qf_entry.lnum - 3, 0]),
        \ 'border': [],
        \ 'title': "Preview"
        \ })
endfunction
