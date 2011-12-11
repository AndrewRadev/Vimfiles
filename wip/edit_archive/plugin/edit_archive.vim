autocmd BufReadCmd *.rar call s:ReadArchive(expand('<afile>'))
autocmd BufReadCmd *.zip call s:ReadArchive(expand('<afile>'))

function! s:ReadArchive(archive)
  exe 'edit '.tempname()
  let b:archive = edit_archive#archive#New(a:archive)

  let banner = ['File: '.a:archive]
  let banner += [repeat('=', len(banner[0]))]
  call append(0, banner)

  let contents = b:archive.FileList()
  call append(line('$'), contents)

  nnoremap <buffer> <cr> :call <SID>EditFile()<cr>
endfunction

function! s:EditFile()
  let tempfile = b:archive.Tempfile(expand('<cfile>'))
  exe 'edit '.tempfile
  set readonly
endfunction
