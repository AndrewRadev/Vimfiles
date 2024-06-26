" Note: depends on splitjoin

command! -range=0 -nargs=* -complete=file Open call s:Open(<count>, <f-args>)

function! Open(path)
  call s:Open(0, a:path)
endfunction

" Alias for some plugins
function! OpenURL(path)
  call s:Open(0, a:path)
endfunction

function! s:Open(count, ...)
  if a:count > 0
    " then the path is visually selected
    let path = sj#GetMotion('gv')
  elseif a:0 == 0
    " then the path is the filename under the cursor
    let path = s:GetCursorUrl()
  else
    " it has been given as an argument
    let path = join(a:000, ' ')
  endif

  if path == ''
    echomsg "Can't find URL under cursor"
    return
  endif

  call s:OpenUrl(path)
  echomsg 'Opening '.path
endfunction

" Open URLs with the system's default application. Works for both local and
" remote paths.
function! s:OpenUrl(url)
  let url = shellescape(a:url)

  if has('mac')
    silent call system('open '.url)
  elseif has('unix')
    if executable('xdg-open')
      silent call system('xdg-open '.url.' 2>&1 > /dev/null &')
    else
      echoerr 'You need to install xdg-open to be able to open urls'
      return
    end
  elseif has('win32') || has('win64')
    silent exe "! start ".a:url
  else
    echoerr 'Don''t know how to open a URL on this system'
    return
  end
endfunction

function! s:GetCursorUrl()
  let url_pattern = highlighturl#default_pattern()
  let saved_view = winsaveview()

  try
    if sj#SearchUnderCursor(url_pattern) <= 0
      return ''
    endif

    let start_col = col('.')
    call sj#SearchUnderCursor(url_pattern, 'e')
    return sj#GetCols(start_col, col('.'))
  finally
    call winrestview(saved_view)
  endtry
endfunction
