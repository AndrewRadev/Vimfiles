"
" Public:
"
command! -count=0 -nargs=* -complete=file Open call s:Open(<count>, <f-args>)

function! Open(path)
  call s:Open(0, a:path)
endfunction

" Alias for some plugins
function! OpenURL(path)
  call s:Open(0, a:path)
endfunction

"
" Private:
"
function! s:Open(count, ...)
  if a:count > 0
    " then the path is visually selected
    let path = s:GetMotion('gv')
  elseif a:0 == 0
    " then the path is the filename under the cursor
    let path = expand('<cfile>')
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

" Execute the normal mode motion "motion" and return the text it marks. Note
" that the motion needs to include a visual mode key, like "V", "v" or "gv".
function! s:GetMotion(motion)
  let saved_cursor   = getpos('.')
  let saved_reg      = getreg('z')
  let saved_reg_type = getregtype('z')

  exec 'normal! '.a:motion.'"zy'
  let text = @z

  call setreg('z', saved_reg, saved_reg_type)
  call setpos('.', saved_cursor)

  return text
endfunction
