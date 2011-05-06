xmap so :<c-u>call <SID>ExtractVar()<cr>
nmap si :<c-u>call <SID>InlineVar()<cr>

" TODO not working with EOL
function! s:ExtractVar()
  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

  let var_name = input("Variable name: ")

  normal! gv"zy
  let body = @z
  let @z = var_name
  normal! gv"zp
  let @z = var_name . ' = ' . body
  normal! O
  normal! "zp==

  call setreg('z', original_reg, original_reg_type)
endfunction

function! s:InlineVar()
  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

  let declaration_pattern = '\v^.{-}(\k+)\s+\=\s+(.*)$'
  let line = getline('.')

  if line !~ declaration_pattern
    echohl WarningMsg | echo "Couldn't find a declaration on the current line" | echohl None
    return
  endif

  let var_name = lib#ExtractRx(line, declaration_pattern, '\1')
  let body     = lib#ExtractRx(line, declaration_pattern, '\2')

  normal! dd

  let [from, to] = GetScopeLimits()
  exe from.','.to.'s/\<'.var_name.'\>/'.escape(body, '/').'/gc'

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
