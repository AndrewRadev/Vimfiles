let b:surround_{char2nr('*')} = "**\r**"
let b:surround_{char2nr('_')} = "_\r_"

set completefunc=googlescribe#Complete

hi link markdownItalic Normal

RunCommand call MarkdownRun(expand('%'))
if !exists('*MarkdownRun')
  function MarkdownRun(fname)
    let markdown_buffer = bufname('%')

    if !exists('b:preview_file') || bufwinnr(b:preview_file) < 0
      let b:preview_file = tempname().'.html'
      exe "split ".b:preview_file
      call s:SwitchWindow(markdown_buffer)
    endif

    call system('markdown '.shellescape(a:fname).' > '.b:preview_file)
    call s:SwitchWindow(b:preview_file)
    silent edit!
    set ft=html
    call s:SwitchWindow(markdown_buffer)
  endfunction
endif

command! -count=0 -nargs=1 Link call s:Link(<count>, <f-args>)
function! s:Link(count, url)
  if a:count == 0
    " then no visual selection, select the closest word
    normal! viw
  endif

  let saved_register      = getreg('z', 1)
  let saved_register_mode = getregtype('z')

  normal! gv"zd
  let text = @z
  let link = printf('[%s](%s)', text, a:url)
  exe 'normal! i'.link

  call setreg('z', saved_register, saved_register_mode)
endfunction

function! s:SwitchWindow(bufname)
  let window = bufwinnr(a:bufname)
  exe window."wincmd w"
endfunction
