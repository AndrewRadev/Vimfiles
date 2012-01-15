" TODO (2012-01-11) Just as markdown
command! Compile call s:Compile()
function! s:Compile()
  let file = expand('%')
  new
  exe '%!coffee -c -p '.file
  set ft=javascript
  set nomodified
  normal! zR
endfunction

RunCommand Compile
