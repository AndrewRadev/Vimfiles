" Note: Depends on splitjoin.vim

xmap so :<c-u>call <SID>ExtractVar()<cr>
nmap si :<c-u>call <SID>InlineVar()<cr>

function! s:ExtractVar()
  let saved_view = winsaveview()
  let var_name = input("Variable name: ")

  if exists('b:extract_var_template')
    let extract_var_template = b:extract_var_template
  else
    let extract_var_template = '%s = %s'
  endif

  let body = sj#GetMotion('gv')
  call sj#ReplaceMotion('gv', var_name)

  let declaration = printf(extract_var_template, var_name, body)
  call append(line('.') - 1, declaration)

  " Indent and position at the start
  normal! k==0

  if search('${[^}]\+}', 'Wc', line('.'))
    " delete the first '$'
    normal! "_x
    " remove the surrounding curly brackets
    let placeholder = sj#GetMotion('vi{')
    call sj#ReplaceMotion('va{', placeholder)

    if len(placeholder) > 1
      exe "normal! v".(len(placeholder) - 1)."l\<c-g>"
    else
      exe "normal! v\<c-g>"
    endif

    " don't restore cursor position
    return
  endif

  call winrestview(saved_view)
endfunction

function! s:InlineVar()
  if exists('b:inline_var_pattern')
    let declaration_pattern = '^.\{-}'.b:inline_var_pattern.'\s*$'
  else
    let declaration_pattern = '\v^.{-}(\k+)\s+\=\s+(.*)$'
  endif

  let line = getline('.')

  if line !~ declaration_pattern
    echohl WarningMsg | echo "Couldn't find a declaration on the current line" | echohl None
    return
  endif

  let var_name = s:ExtractRx(line, declaration_pattern, '\1')
  let body     = s:ExtractRx(line, declaration_pattern, '\2')

  delete _

  let [from, to] = GetScopeLimits()
  keeppatterns exe from.','.to.'s/\<'.var_name.'\>/'.escape(body, '\/&').'/gc'
endfunction

function! GetScopeLimits()
  let indent = indent(line('.'))

  " first, go upwards
  let current  = line('.')
  let previous = prevnonblank(current - 1)
  while current > 0 && indent(previous) >= indent
    let current  = previous
    let previous = prevnonblank(current - 1)
  endwhile

  let from = current

  " then, go downwards
  let current = line('.')
  let next    = nextnonblank(current + 1)
  let last    = line('$')
  while current < last && indent(next) >= indent
    let current = next
    let next    = nextnonblank(current + 1)
  endwhile

  let to = current

  return [from, to]
endfunction

" Extracts a regex match from a string.
" Original in autoload/lib.vim
function! s:ExtractRx(expr, pat, sub)
  let rx = a:pat

  if stridx(a:pat, '^') != 0
    let rx = '^.*'.rx
  endif

  if strridx(a:pat, '$') + 1 != strlen(a:pat)
    let rx = rx.'.*$'
  endif

  return substitute(a:expr, rx, a:sub, '')
endfunction
