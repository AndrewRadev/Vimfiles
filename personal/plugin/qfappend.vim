" If you've executed a grep/ack command and you have a bunch of stuff in your
" quickfix window, but want to add another grep to it, this could help:
"
"   :Ack ProjectCollaborator
"   :Qfappend Ack UserCollaborator
"
" This will add the new search results to the end of the quickfix list,
" instead of replacing it. You could also put swap the order by using
" :Qfprepend
"
"   :Ack ProjectCollaborator
"   :Qfprepend Ack UserCollaborator
"
" Duplicates should automatically be removed (two hits on the same line in the
" same file). However, the order is going to be the exact order of the first
" list + second list. To sort the current quickfix list alphabetically on the
" filename, use :Qfsort
"
"   :Ack ProjectCollaborator
"   :Qfappend Ack UserCollaborator
"   :Qfsort
"
" You can also provide :Qfsort with a command and it'll execute that first,
" allowing you to do:
"
"   :Ack ProjectCollaborator
"   :Qfsort Qfappend Ack UserCollaborator
"

"
" Public interface
"
command! -nargs=* -complete=command Qfappend call s:Qfappend(<q-args>)
command! -nargs=* -complete=command Qfprepend call s:Qfprepend(<q-args>)
command! -nargs=* -complete=command Qfsort call s:Qfsort(<q-args>)

"
" Implementation
"
function! s:Qfappend(command)
  let qflist = getqflist()
  exe a:command
  call extend(qflist, getqflist())

  call setqflist(qflist)
endfunction

function! s:Qfprepend(command)
  let qflist = getqflist()
  exe a:command
  call extend(qflist, getqflist(), 0)

  call setqflist(qflist)
endfunction

function! s:Qfsort(command)
  if a:command != ''
    " there's a quickfix-related command given, execute it first
    try
      exe a:command
    catch
      " don't try to sort if there's an error, just bail out
      echoerr v:exception
      return
    endtry
  endif

  let qflist = copy(getqflist())
  call sort(qflist, function('s:QfsortCompare'))
  call setqflist(qflist)
endfunction

function! s:QfsortCompare(x, y)
  let x_name = bufname(a:x.bufnr)
  let y_name = bufname(a:y.bufnr)

  if x_name < y_name
    return -1
  elseif x_name > y_name
    return 1
  else
    return 0
  else
endfunction
