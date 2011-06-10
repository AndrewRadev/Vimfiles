let b:surround_{char2nr('*')} = "**\r**"
let b:surround_{char2nr('_')} = "_\r_"

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

function! s:SwitchWindow(bufname)
  let window = bufwinnr(a:bufname)
  exe window."wincmd w"
endfunction
