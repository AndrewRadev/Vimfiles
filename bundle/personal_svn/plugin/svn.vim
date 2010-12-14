" Open up the svn log for the current directory in a new window.
command! SvnLog call s:SvnLog()
function! s:SvnLog()
  if !exists('g:svn_log_size')
    let g:svn_log_size = 50
  endif

  new
  exe 'r!svn log -v -l '.g:svn_log_size
  set nomodified
  normal! gg
  set ft=SVNlog
endfunction

" Open up the current status of the working tree in a new window
command! SvnStatus call s:SvnStatus()
function! s:SvnStatus()
  new
  r!svn status
  set nomodified
  normal! gg
  set ft=SVNstatus
endfunction
