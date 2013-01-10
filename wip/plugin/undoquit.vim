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
  let window_data = { 'filename': expand('%') }

  if len(tabpagebuflist()) == 1
    " then this is the last buffer in this tab
    let window_data.neighbour_buffer = ''
    let window_data.open_command     = 'tabnew'
    return window_data
  endif

  " attempt to store neighbouring buffers as split-base-points
  for direction in ['j', 'k', 'h', 'l']
    if s:UseNeighbourWindow(direction, window_data)
      return window_data
    endif
  endfor

  " default case, no listed buffers around
  let window_data.neighbour_buffer = ''
  let window_data.open_command     = 'edit'
  return window_data
endfunction

function! s:UseNeighbourWindow(direction, window_data)
  let current_bufnr = bufnr('%')
  let current_winnr = winnr()

  try
    exe 'wincmd '.a:direction
    let bufnr = bufnr('%')
    if buflisted(bufnr) && bufnr != current_bufnr
      " then we have a neighbouring buffer above
      let a:window_data.neighbour_buffer = expand('%')
      let a:window_data.open_command     = 'rightbelow split'
      return 1
    else
      return 0
    endif
  finally
    exe current_winnr.'wincmd w'
  endtry
endfunction
