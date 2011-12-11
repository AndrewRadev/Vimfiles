function! edit_archive#rar#New(name)
  return extend(edit_archive#archive#Common(a:name), {
        \ 'FileList':    function('edit_archive#rar#FileList'),
        \ 'ExtractFile': function('edit_archive#rar#ExtractFile'),
        \ })
endfunction

function! edit_archive#rar#FileList() dict
  return split(system('unrar lb ' . self.name), "\n")
endfunction

function! edit_archive#rar#ExtractFile(filename) dict
  call system('unrar x '.self.name.' '.a:filename)
endfunction
