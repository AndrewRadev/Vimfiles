command! Diffsplit call s:Diffsplit()
function! s:Diffsplit()
  let files              = {}
  let current_file       = ''
  let file_start_pattern = 'diff --git \zs.\+\ze '

  let saved_view = winsaveview()
  normal! gg0
  let first_line = search(file_start_pattern, 'W')
  call winrestview(saved_view)

  if first_line <= 0
    echoerr "Couldn't find pattern: ".file_start_pattern
    return
  endif

  for lineno in range(first_line, line('$'))
    let line = getline(lineno)

    if line =~ file_start_pattern
      let current_file = matchstr(line, file_start_pattern)
      let files[current_file] = []
    elseif current_file == ''
      echoerr "File not detected for line: ".line
    else
      call add(files[current_file], line)
    endif
  endfor

  let dir = tempname()
  call mkdir(dir)

  tabnew
  exe 'tcd '.dir

  for [filename, lines] in items(files)
    let parent = fnamemodify(filename, ':h')
    if !isdirectory(parent)
      call mkdir(parent, 'p')
    endif

    call writefile(lines, filename . '.diff')
  endfor

  if exists(':NERDTree')
    NERDTree
  endif
endfunction
