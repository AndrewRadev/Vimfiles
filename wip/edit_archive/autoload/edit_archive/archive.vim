function! edit_archive#archive#New(name)
  if a:name =~ '\.rar$'
    return edit_archive#rar#New(a:name)
  elseif a:name =~ '\.zip$'
    return edit_archive#zip#New(a:name)
  else
    throw "Unrecognized archive"
  endif
endfunction

function! edit_archive#archive#Common(name)
  return {
        \ 'name':             fnamemodify(a:name, ':p'),
        \ '_tempdir':         '',
        \
        \ 'FileList':    function('edit_archive#archive#FileList'),
        \ 'ExtractFile': function('edit_archive#archive#ExtractFile'),
        \ 'Tempfile':    function('edit_archive#archive#Tempfile'),
        \ }
endfunction

function! edit_archive#archive#FileList() dict
  throw "not implemented"
endfunction

function! edit_archive#archive#ExtractFile(filename) dict
  throw "not implemented"
endfunction

function! edit_archive#archive#Tempfile(filename) dict
  if self._tempdir == ''
    let self._tempdir = tempname()
    call mkdir(self._tempdir)
  endif

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call self.ExtractFile(a:filename)
  exe 'cd '.cwd

  return self._tempdir.'/'.a:filename
endfunction
