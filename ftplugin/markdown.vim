setlocal shiftwidth=4

let b:surround_{char2nr('*')} = "**\r**"
let b:surround_{char2nr('_')} = "_\r_"

hi link markdownItalic Normal

compiler markdownlint

" call SetupPreview('html', 'markdown %s')
RunCommand silent call system('quickmd '.shellescape(expand('%')).' 2>&1 > /dev/null &')

xnoremap ! :<c-u>call <SID>VisualRun()<cr>
function! s:VisualRun()
  let target_lines = getbufline('%', line("'<"), line("'>"))
  silent call system('quickmd - 2>&1 > /dev/null &', target_lines)
endfunction

let b:outline_pattern = '^#\+\s\+\w'

command! -buffer -range=0 -nargs=* Link call s:Link(<count>, <f-args>)
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

command! -buffer -nargs=* -complete=filetype
      \ VimdocCode call s:VimdocCode(<f-args>)
function! s:VimdocCode(...)
  let start_line = search('^>$', 'bnW')
  if !start_line
    return
  endif

  let end_line = search('^<$', 'nW')
  if !end_line
    return
  endif

  if a:0 > 0
    let opening_markup = '``` '.a:1
  else
    let opening_markup = '```'
  endif

  call setline(start_line, opening_markup)
  call setline(end_line, '```')

  call append(start_line - 1, [''])
  call append(end_line + 1, [''])

  exe start_line.','.end_line.'s/^    //'
endfunction
