nnoremap <Return> :SvnDiff<cr>
command! SvnDiff call s:SvnDiff()
function! s:SvnDiff()
	let lineno = search('r\d\+', 'bcnW')
	if lineno < 0
		return
	endif

	let revision = lib#ExtractRx(getline(lineno), 'r\(\d\+\)', '\1')
	rightbelow new
  exe 'r!svn diff . -r'.revision
	set nomodified
	set ft=diff
	normal gg
endfunction
