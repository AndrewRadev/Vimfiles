function! r#StartConsole(filename) abort
  terminal R --no-save
  tnoremap <buffer> <esc> <c-\><c-n>

  call term_sendkeys(bufnr(), "require('colorout')\n")
  call term_sendkeys(bufnr(), "source('" .. escape(a:filename, "'") .. "')\n")
endfunction
