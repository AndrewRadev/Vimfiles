" Note: depends on splitjoin

command! -count=0 -nargs=* -complete=file Open call s:Open(<count>, <f-args>)

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
  else
    echoerr 'Don''t know how to open a URL on this system'
    return
  end
endfunction

function! s:GetCursorUrl()
  let cfile = expand('<cfile>')
  let saved_cursor = getpos('.')

  try
    if sj#SearchUnderCursor('\V'.cfile) <= 0
      return cfile
    endif

    let start_col = col('.')
    call sj#SearchUnderCursor('\V'.cfile.'\m\%(\f\|[?!=&]\)*', 'e')
    return sj#GetCols(start_col, col('.'))
  finally
    call setpos('.', saved_cursor)
  endtry
endfunction
