" Define what color the private area will be
hi rubyPrivateArea cterm=underline gui=underline

function! s:MarkPrivateArea()
  " Clear out any previous matches
  call clearmatches()

  " Store the current view, in order to restore it later
  let saved_view = winsaveview()

  " start at the last char in the file and wrap for the
  " first search to find match at start of file
  normal! G$
  let flags = "w"
  while search('\<private\>', flags) > 0
    let flags = "W"

    if s:CurrentSyntaxName() !~# "rubyAccess"
      " it's not a real access modifier, keep going
      continue
    endif

    let start_line = line('.')

    " look for the matching "end"
    let saved_position = getpos('.')
    while search('\<end\>', 'W') > 0
      if s:CurrentSyntaxName() !~# "rubyClass"
        " it's not an end that closes a class, keep going
        continue
      endif

      let end_line = line('.') - 1
      call matchadd('rubyPrivateArea', '\%>'.start_line.'l\<def\>\%<'.end_line.'l')
      break
    endwhile

    " restore where we were before we started looking for the "end"
    call setpos('.', saved_position)
  endwhile

  " We're done highlighting, restore the view to what it was
  call winrestview(saved_view)
endfunction

function! s:CurrentSyntaxName()
  return synIDattr(synID(line("."), col("."), 0), "name")
endfunction

augroup rubyPrivateArea
  autocmd!

  " Initial marking
  autocmd BufEnter <buffer> call <SID>MarkPrivateArea()

  " Mark upon writing
  autocmd BufWrite <buffer> call <SID>MarkPrivateArea()

  " Mark when not moving the cursor for 'timeoutlen' time
  " autocmd CursorHold <buffer> call <SID>MarkPrivateArea()
augroup END
