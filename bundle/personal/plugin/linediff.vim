" TODO update buffer from and to on change

let s:linediff_first  = []
let s:linediff_second = []

sign define linediff_first  text=1- texthl=Search
sign define linediff_second text=2- texthl=Search

command! -range -bang Linediff call s:Linediff(<line1>, <line2>)
function! s:Linediff(from, to)
  if len(s:linediff_first) == 0
    let s:linediff_first = [bufnr('%'), &filetype, a:from, a:to]
    exe "sign place 11 name=linediff_first line=".a:from." file=".expand('%')
    exe "sign place 12 name=linediff_first line=".a:to." file=".expand('%')
  elseif len(s:linediff_second) == 0
    let s:linediff_second = [bufnr('%'), &filetype, a:from, a:to]
    exe "sign place 21 name=linediff_second line=".a:from." file=".expand('%')
    exe "sign place 22 name=linediff_second line=".a:to." file=".expand('%')

    call s:PerformDiff(s:linediff_first, s:linediff_second)
  else
    call s:LinediffReset()
    call s:Linediff(a:from, a:to)
  endif

  redraw!
endfunction

command! LinediffReset call s:LinediffReset()
function! s:LinediffReset()
  let s:linediff_first  = []
  let s:linediff_second = []
  sign unplace *
endfunction

function! s:PerformDiff(first, second)
  call s:CreateDiffBuffer(a:first, "tabedit")
  call s:CreateDiffBuffer(a:second, "rightbelow vsplit")
endfunction

function! s:CreateDiffBuffer(properties, edit_command)
  let [bufno, ft, from, to] = a:properties

  let content   = getbufline(bufno, from, to)
  let temp_file = tempname()

  exe a:edit_command . " " . temp_file
  call append(0, content)
  normal! Gdd
  set nomodified

  call s:SetupDiffBuffer(bufno, ft, from, to)
  diffthis
endfunction

function! s:UpdateOriginalBuffer()
  let lines           = getbufline('%', 0, '$')
  let current_buffer  = bufnr('%')
  let original_buffer = b:original_buffer
  let from            = b:from
  let to              = b:to

  exe original_buffer."buffer"
  let pos = getpos('.')
  call cursor(from, 1)
  exe "normal! ".(to - from + 1)."dd"
  call append(from - 1, lines)
  call setpos(pos)
  let ft = &ft

  exe current_buffer."buffer"
  call s:SetupDiffBuffer(original_buffer, ft, from, to)
endfunction

function! s:SetupDiffBuffer(bufno, ft, from, to)
  let b:original_buffer = a:bufno
  let b:from            = a:from
  let b:to              = a:to

  let statusline = printf('[%s:%d-%d]', bufname(b:original_buffer), b:from, b:to)
  if &statusline =~ '%f'
    let statusline = substitute(&statusline, '%f', statusline, '')
  endif
  exe "setlocal statusline=".escape(statusline, ' ')
  exe "set filetype=".a:ft

  autocmd BufWrite <buffer> call s:UpdateOriginalBuffer()
endfunction
