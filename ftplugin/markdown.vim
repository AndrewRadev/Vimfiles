let b:surround_{char2nr('*')} = "**\r**"
let b:surround_{char2nr('_')} = "_\r_"

RunCommand call MarkdownRun(expand('%'))
function! MarkdownRun(fname)
  let tempfile = tempname()
  call system('markdown '.shellescape(a:fname).' > '.tempfile)
  call system('firefox '.tempfile.' &')
endfunction
