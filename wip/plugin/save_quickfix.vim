command! -nargs=1                                       SaveQuickfix   call s:SaveQuickfix(<f-args>)
command! -nargs=1 -complete=custom,s:SavedQuickfixNames LoadQuickfix   call s:LoadQuickfix(<f-args>)
command! -nargs=1 -complete=custom,s:SavedQuickfixNames DeleteQuickfix call s:DeleteQuickfix(<f-args>)
command! -nargs=0                                       ClearQuickfix  call s:ClearQuickfix()

function! s:SaveQuickfix(name)
  if !exists('g:saved_quickfix')
    let g:saved_quickfix = {}
  endif

  let g:saved_quickfix[a:name] = getqflist()
endfunction

function! s:LoadQuickfix(name)
  if !exists('g:saved_quickfix') || !has_key(g:saved_quickfix, a:name)
    echo 'No saved quickfix with name "'.a:name.'"'
    return
  endif

  call setqflist(g:saved_quickfix[a:name])
  copen
endfunction

function! s:DeleteQuickfix(name)
  if !exists('g:saved_quickfix') || !has_key(g:saved_quickfix, a:name)
    return
  endif

  call remove(g:saved_quickfix, a:name)
endfunction

function! s:ClearQuickfix()
  if exists('g:saved_quickfix')
    unlet g:saved_quickfix
  endif
endfunction

function! s:SavedQuickfixNames(_argument_lead, _command_line, _cursor_position)
  if !exists('g:saved_quickfix')
    let g:saved_quickfix = {}
  endif

  return join(sort(keys(g:saved_quickfix)), "\n")
endfunction
