setlocal shiftwidth=4

let b:surround_{char2nr('*')} = "**\r**"
let b:surround_{char2nr('_')} = "_\r_"

hi link markdownItalic Normal

call SetupPreview('html', 'markdown %s')
RunCommand Preview

command! -count=0 -nargs=* Link call s:Link(<count>, <f-args>)
function! s:Link(count, ...)
  if a:count == 0
    " then no visual selection, select the closest word
    normal! viw
  endif

  let saved_register      = getreg('z', 1)
  let saved_register_mode = getregtype('z')

  normal! gv"zd
  let text = @z
  if a:0 > 0
    let url  = join(a:000, ' ')
    let link = printf('[%s](%s)', text, url)
  else
    let link = printf('[%s][]', text)
  endif
  exe 'normal! i'.link

  call setreg('z', saved_register, saved_register_mode)
endfunction
