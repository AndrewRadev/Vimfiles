RunCommand call PandocRun(expand('%'))
function! PandocRun(fname)
  let tempfile = tempname()
  call system('pandoc '.shellescape(a:fname).' > '.tempfile)
  call system('firefox '.tempfile.' &')
endfunction
