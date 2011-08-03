let s:linediff_first  = []
let s:linediff_second = []

command! -range LineDiff call s:LineDiff(<line1>, <line2>)
function! s:LineDiff(from, to)
  " TODO Add buffer data, use getbuflines
  if len(s:linediff_first) == 0
    let s:linediff_first = [a:from, a:to]
  else
    let s:linediff_second = [a:from, a:to]

    call s:PerformDiff(s:linediff_first, s:linediff_second)

    let s:linediff_first  = []
    let s:linediff_second = []
  endif
endfunction

" TODO Set filetype properly
function! s:PerformDiff(first, second)
  " TODO sj#GetLines
  let first_content  = sj#GetLines(a:first[0], a:first[1])
  let second_content = sj#GetLines(a:second[0], a:second[1])

  let first_file  = tempname()
  let second_file = tempname()

  tabnew

  " TODO refactor
  exe "edit ".first_file
  call append(0, first_content)
  normal! Gdd
  set nomodified
  diffthis

  exe "vsplit ".second_file
  call append(0, second_content)
  normal! Gdd
  set nomodified
  diffthis
endfunction
