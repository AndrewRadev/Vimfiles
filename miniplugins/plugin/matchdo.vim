command! -nargs=1 -range=% Matchdo call s:Matchdo(<line1>, <line2>, <q-args>)

function! s:Matchdo(start_line, end_line, command) abort
  " Save the current cursor position, restore it after the function is over.
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  let stopline = 0

  if a:start_line == 1
    " The range is the whole file, we start at the end of the file and wrap
    " around so we can cover a match at line 1, column 1:
    normal! G$
    let flags = 'w'
  else
    " we start just before the start line
    exe 'normal! ' .. (a:start_line - 1) .. 'G$'
    let flags = 'W'
    let stopline = a:end_line
  endif

  while search(@/, flags, stopline) > 0
    exe a:command

    " Move to the end of the changed text to avoid matching it again:
    normal! g`]

    let flags = 'W'
    let stopline = a:end_line
  endwhile
endfunction
