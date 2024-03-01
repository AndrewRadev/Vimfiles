" Calling :Timestamp will try to convert the word under the cursor. Selecting
" an area in visual mode will pass it to `date` and replace the entire area.
"
command! -range=0 Timestamp call s:Timestamp(<count>)

function! s:Timestamp(count) abort
  let is_visual = a:count > 0

  if !executable('date')
    echohl Error | echomsg "Couldn't find `date` executable" | echohl NONE
    return
  endif

  if is_visual
    let description = s:GetLastSelectedText()
  else
    let description = expand('<cword>')
  endif

  if description =~ '^\d\+$'
    " it's a numeric timestamp, convert manually:
    if len(description) == 13
      " it's milliseconds
      let ts = str2nr(strpart(description, 0, 10))
    else
      " consider it seconds
      let ts = str2nr(description)
    endif

    let output = strftime("%c", ts)
  else
    " consider it as input to the date command
    let output = trim(system('date --date=' .. shellescape(description)))
    if v:shell_error
      echohl Error | echomsg "Got error: " .. output | echohl NONE
      return
    endif
  endif

  if is_visual
    call s:ReplaceArea('gv', output)
  else
    call s:ReplaceArea('viw', output)
  endif
endfunction

function! s:GetLastSelectedText() abort
  let saved_view = winsaveview()

  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

  normal! gv"zy
  let text = @z

  call setreg('z', original_reg, original_reg_type)
  call winrestview(saved_view)

  return text
endfunction

function! s:ReplaceArea(motion, text) abort
  let saved_view = winsaveview()

  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

  let @z = a:text
  exe 'normal! ' .. a:motion .. '"zp'

  call setreg('z', original_reg, original_reg_type)
  call winrestview(saved_view)
endfunction
