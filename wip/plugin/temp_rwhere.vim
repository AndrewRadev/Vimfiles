" Find where a partial is used. Maybe also add a fallback that just wraps :Ack for everything else?
command! Rwhere call s:Rwhere()
function! s:Rwhere()
  if search('render.*[''"]\f*\%#\f*[''"]', 'bcn', line('.')) <= 0
    echomsg "Don't see a `render` call around the cursor"
    return
  endif

  let partial_string = expand('<cfile>')

  let query = partial_string
  exe 'Ack '.shellescape(query)
endfunction
