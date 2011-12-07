autocmd BufReadCmd *.rar call s:ReadRarFile(expand('<afile>'))

function! s:ReadRarFile(archive)
  exe 'edit '.tempname()
  let b:archive_name = fnamemodify(a:archive, ':p')

  let banner = ['File: '.a:archive]
  let banner += [repeat('=', len(banner[0]))]
  call append(0, banner)

  let contents = split(system('unrar lb '.a:archive), "\n")
  call append(line('$'), contents)

  nnoremap <buffer> <cr> :call <SID>EditFile()<cr>
endfunction

function! s:EditFile()
  let archive  = b:archive_name
  let filename = expand('<cfile>')

  let cwd     = getcwd()
  let tempdir = tempname()
  call mkdir(tempdir)
  exe 'cd '.tempdir

  call system('unrar x '.archive.' '.filename)

  exe 'edit '.tempdir.'/'.filename
  set readonly
endfunction
