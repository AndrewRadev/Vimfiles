setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=indent
setlocal nofoldenable

setlocal commentstring=#\ %s

command! -buffer Flatten YAMLToggleFlatness

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

nnoremap <buffer> zp :call <SID>PrintPath()<cr>
nnoremap <buffer> zy :call <SID>YankPath()<cr>

function! s:PrintPath()
  echomsg s:GetPath()
endfunction

function! s:YankPath()
  let path = s:GetPath()
  echomsg 'Yanked: "'.path.'" to all clipboards'

  let @" = path
  let @* = path
  let @+ = path
endfunction

function! s:GetPath()
  let saved_view = winsaveview()

  let line = getline('.')
  let indent = indent(line('.'))
  let path = []

  let extraction_pattern = '^\s*\zs[[:keyword:]/]\+\ze:'

  if line =~ extraction_pattern
    let path = [matchstr(line, extraction_pattern)]
  endif

  while search('^\s\{,'.(indent - 1).'}[[:keyword:]/]\+:', 'Wb', 1, 0, sj#SkipSyntax(['Comment'])) > 0
    call insert(path, matchstr(getline('.'), extraction_pattern), 0)

    let indent = indent(line('.'))
    if indent <= 0
      break
    endif
  endwhile

  call winrestview(saved_view)
  return join(path, '.')
endfunction
