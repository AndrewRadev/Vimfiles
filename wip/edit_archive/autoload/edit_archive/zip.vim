function! edit_archive#zip#New(name)
  return extend(edit_archive#archive#Common(a:name), {
        \ 'FileList':    function('edit_archive#zip#FileList'),
        \ 'ExtractFile': function('edit_archive#zip#ExtractFile'),
        \ })
endfunction

function! edit_archive#zip#FileList() dict
  let file_list = []
  for line in split(system('unzip -qql ' . self.name), "\n")
    call add(file_list, substitute(line, '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$', '\1', ''))
  endfor
  return file_list
endfunction

function! edit_archive#zip#ExtractFile(filename) dict
  call system('unzip '.self.name.' '.a:filename)
endfunction
