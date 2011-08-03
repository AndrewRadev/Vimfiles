" TODO visual indication, marks
" TODO feedback on which lines are set -- statusline
" TODO update original buffer on save

let s:linediff_first  = []
let s:linediff_second = []

command! -range LineDiff call s:LineDiff(<line1>, <line2>)
function! s:LineDiff(from, to)
  if len(s:linediff_first) == 0
    let s:linediff_first = [bufnr('%'), &filetype, a:from, a:to]
  else
    let s:linediff_second = [bufnr('%'), &filetype, a:from, a:to]

    call s:PerformDiff(s:linediff_first, s:linediff_second)

    let s:linediff_first  = []
    let s:linediff_second = []
  endif
endfunction

function! s:PerformDiff(first, second)
  call s:CreateDiffBuffer(a:first, "tabedit")
  call s:CreateDiffBuffer(a:second, "vsplit")
endfunction

function! s:CreateDiffBuffer(properties, edit_command)
  let [bufno, ft, from, to] = a:properties

  let content   = getbufline(bufno, from, to)
  let temp_file = tempname()

  exe a:edit_command . " " . temp_file
  call append(0, content)
  normal! Gdd
  set nomodified
  exe "set filetype=".ft
  diffthis
endfunction
