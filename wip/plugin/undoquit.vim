autocmd QuitPre * call s:SaveWindowCloseHistory()

nnoremap <c-w>u :call <SID>UndoCloseWindow()<cr>

function! s:SaveWindowCloseHistory()
  if !buflisted(expand('%'))
    return
  endif

  if !exists('g:window_close_history')
    let g:window_close_history = []
  endif

  let window_data = s:WindowData()

  call add(g:window_close_history, window_data)
endfunction

function! s:UndoCloseWindow()
  if !exists('g:window_close_history') || empty(g:window_close_history)
    echo "No closed windows to undo"
    return
  endif

  let window_data = remove(g:window_close_history, -1)

  if window_data.neighbour_buffer != '' && bufnr(window_data.neighbour_buffer) >= 0
    exe 'buffer '.bufnr(window_data.neighbour_buffer)
  endif

  exe window_data.open_command.' '.window_data.filename
endfunction

function! s:WindowData()
  let current_bufnr = bufnr('%')
  let current_winnr = winnr()
  let window_data   = { 'filename': expand('%') }

  if len(tabpagebuflist()) == 1
    " then this is the last buffer in this tab
    let window_data.neighbour_buffer = ''
    let window_data.open_command     = 'tabnew'
    return window_data
  endif

  try
    wincmd j
    let bufnr = bufnr('%')
    if buflisted(bufnr) && bufnr != current_bufnr
      " then we have a neighbouring buffer below
      let window_data.neighbour_buffer = expand('%')
      let window_data.open_command     = 'leftabove split'
      return window_data
    endif
  finally
    exe current_winnr.'wincmd w'
  endtry

  try
    wincmd k
    let bufnr = bufnr('%')
    if buflisted(bufnr) && bufnr != current_bufnr
      " then we have a neighbouring buffer above
      let window_data.neighbour_buffer = expand('%')
      let window_data.open_command     = 'rightbelow split'
      return window_data
    endif
  finally
    exe current_winnr.'wincmd w'
  endtry

  try
    wincmd h
    let bufnr = bufnr('%')
    if buflisted(bufnr) && bufnr != current_bufnr
      " then we have a neighbouring buffer to the left
      let window_data.neighbour_buffer = expand('%')
      let window_data.open_command     = 'rightbelow vsplit'
      return window_data
    endif
  finally
    exe current_winnr.'wincmd w'
  endtry

  try
    wincmd l
    let bufnr = bufnr('%')
    if buflisted(bufnr) && bufnr != current_bufnr
      " then we have a neighbouring buffer to the right
      let window_data.neighbour_buffer = expand('%')
      let window_data.open_command     = 'leftabove vsplit'
      return window_data
    endif
  finally
    exe current_winnr.'wincmd w'
  endtry

  " Default case, no listed buffers around
  let window_data.neighbour_buffer = ''
  let window_data.open_command     = 'edit'
  return window_data
endfunction
