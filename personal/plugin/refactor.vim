xmap so :<c-u>call <SID>ExtractVar()<cr>
nmap si :<c-u>call <SID>InlineVar()<cr>

function! s:ExtractVar()
  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

  let var_name = input("Variable name: ")

  if exists('b:extract_var_template')
    let extract_var_template = b:extract_var_template
  else
    let extract_var_template = '%s = %s'
  endif

  normal! gv"zy
  let body = @z
  let @z = var_name
  normal! gv"zp
  let @z = printf(extract_var_template, var_name, body)
  normal! O
  normal! "zp==

  call setreg('z', original_reg, original_reg_type)
endfunction

function! s:InlineVar()
  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

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

  normal! dd

  let [from, to] = GetScopeLimits()
  exe from.','.to.'s/\<'.var_name.'\>/'.escape(body, '\/').'/gc'

  call setreg('z', original_reg, original_reg_type)
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
