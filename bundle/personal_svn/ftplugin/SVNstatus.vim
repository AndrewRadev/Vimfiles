nnoremap <buffer> - :call <SID>SvnHandleFile()<cr>
function! s:SvnHandleFile()
  let file = expand("<cfile>")
  if (file == "")
    echo 'No file under cursor'
  endif

  if confirm('Add file?', "Yes\nNo") == 1
    normal! ggdG
    exe '!svn add '.file
    r!svn status
    set nomodified
    normal gg
  endif
endfunction
