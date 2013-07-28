command! RunCommand call s:RunCommand(<q-args>)
function! s:RunCommand(args)
  silent exe '!dot -Txlib '.shellescape(expand('%')).' '.a:args.' &'
  redraw!
endfunction
