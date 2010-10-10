RunCommand call LatexRun(expand('%'))
function! LatexRun(fname)
  call system('latex '.a:fname)
  let compiled = substitute(a:fname, '\.latex$', '.dvi', '')
  call system('evince '.compiled.' &')
endfunction
