setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=indent
setlocal nofoldenable

setlocal commentstring=#\ %s

command! -buffer YamlPreview call s:YamlPreview()
function! s:YamlPreview()
  let file_name = expand('%')

  call system('which yaml2json')
  if v:shell_error
    echomsg "Couldn't find yaml2json executable"
  endif

  call system('which jq')
  if v:shell_error
    echomsg "Couldn't find jq executable"
  endif

  let output = systemlist('yaml2json | jq .', join(getbufline('%', 0, line('$')), "\n"))
  if v:shell_error
    echomsg "The `yaml2json` command returned an error: ".join(output, "\n"))
  endif

  new
  set buftype=nofile
  set ft=json
  call append(0, output)
  $delete _
  normal! gg
endfunction

RunCommand YamlPreview
