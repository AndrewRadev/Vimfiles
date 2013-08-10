RunCommand call DotFileRunCommand(<q-args>)
function! DotFileRunCommand(args)
  silent exe '!dot -Txlib '.shellescape(expand('%')).' '.a:args.' &'
  redraw!
endfunction
