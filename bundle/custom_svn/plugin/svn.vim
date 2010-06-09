command! SvnLog call s:SvnLog()
function! s:SvnLog()
  new
  r!svn log -v
  set nomodified
  normal! gg
  set ft=svnlog
endfunction
