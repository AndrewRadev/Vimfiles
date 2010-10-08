" Global to allow usage outside the plugin if necessary.  Might be beneficial
" to extract somewhere as an addition to the public API.
function! NERDTreeIsOpen()
  if exists('t:NERDTreeBufName')
    return (bufwinnr(t:NERDTreeBufName) != -1)
  else
    return 0
  end
endfunction

function! s:NERDTreeMaybeReposition(filename)
  let bufname = bufname('%')

  if NERDTreeIsOpen() && bufname != t:NERDTreeBufName
    let bufnr = bufwinnr(bufname('%'))

    try
      NERDTreeFind
    catch /E716/
      " Ignore non-existence of buffer
    finally
      exe bufnr."wincmd w"
    endtry
  endif
endfunction

command! NERDTreeFollowCurrent call <SID>NERDTreeFollowCurrent()
function! s:NERDTreeFollowCurrent()
  augroup NERDTreeFollowCurrent
    autocmd!

    autocmd BufEnter * call <SID>NERDTreeMaybeReposition(expand('<cfile>'))
  augroup END
endfunction

command! NERDTreeUnfollowCurrent call <SID>NERDTreeUnfollowCurrent()
function! s:NERDTreeUnfollowCurrent()
  augroup NERDTreeFollowCurrent
    autocmd!
  augroup END
endfunction

if exists('g:NERDTreeFollowCurrent') && g:NERDTreeFollowCurrent
  NERDTreeFollowCurrent
endif
