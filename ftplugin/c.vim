setlocal tabstop=8
setlocal shiftwidth=8
setlocal noexpandtab

iabbr null NULL

nmap <buffer> gm :exe "Man ".expand("<cword>")<cr>

let b:outline_pattern = '^\k'

RunCommand !./a.out <args>

nnoremap <buffer> - :call <SID>ToggleAccessOperator()<cr>
xnoremap <buffer> - :call <SID>ToggleAccessOperator()<cr>
function! s:ToggleAccessOperator()
  let saved_cursor = getpos('.')
  let line         = getline('.')

  if line =~ '\k\+->\k'
    s/\k\+\zs->\ze\k/./
  elseif line =~ '\k\+\.\k'
    s/\k\+\zs\.\ze\k/->/
  endif

  call setpos('.', saved_cursor)
endfunction
