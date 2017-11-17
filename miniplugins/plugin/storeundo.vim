command! -nargs=1 StoreUndo call s:StoreUndo(<f-args>)
function! s:StoreUndo(label)
  if !exists('b:stored_undo_state')
    let b:stored_undo_state = {}
  endif

  let b:stored_undo_state[a:label] = undotree()['seq_cur']
endfunction

command! -nargs=1 -complete=custom,s:CompleteUndoStates RestoreUndo call s:RestoreUndo(<f-args>)
function! s:RestoreUndo(label)
  if !exists('b:stored_undo_state')
    let b:stored_undo_state = {}
  endif

  if !has_key(b:stored_undo_state, a:label)
    echoerr a:label.' not found in stored undo states.'
  endif

  exe 'undo '.b:stored_undo_state[a:label]
endfunction

function! s:CompleteUndoStates(A, L, P)
  if !exists('b:stored_undo_state')
    let b:stored_undo_state = {}
  endif

  return join(keys(b:stored_undo_state), "\n")
endfunction
