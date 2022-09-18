" TODO (2022-09-18) Extract into a plugin
" TODO (2022-09-18) Add settings for highlight, bar components etc: https://github.com/Xuyuanp/scrollbar.nvim
" TODO (2022-09-18) Rewrite in Vim9script?

finish

augroup Scrollbar
  autocmd!
  autocmd WinScrolled,VimResized,QuitPre,WinEnter,FocusGained *
        \ call s:ShowScrollbar()
  autocmd WinLeave,BufLeave,BufWinLeave,FocusLost *
        \ call s:HideScrollbar()
augroup END

function s:ShowScrollbar() abort
  let min_size = 3
  let max_size = 10

  let total_lines   = line('$')
  let window_height = winheight(0)
  if total_lines <= window_height
    return
  endif

  let ratio = (total_lines - window_height) * 1.0
  let current_line = line('w$') - window_height
  let bar_size = float2nr(ceil(window_height * window_height / ratio))
  let bar_size = s:Clamp(bar_size, min_size, max_size)

  let content = ['▲'] + split(repeat('█', bar_size - 2), '\zs') + ['▼']

  let [win_row, win_col] = win_screenpos(0)
  let col = win_col + winwidth(0)
  let line = 1 + win_row + float2nr(floor((window_height - bar_size) * (current_line / ratio)))

  if exists('b:scrollbar_popup') && b:scrollbar_popup > 0
    call popup_close(b:scrollbar_popup)
  endif

  let b:scrollbar_popup = popup_create(content, #{
        \ line: line,
        \ col: col,
        \ maxwidth: 1,
        \ maxheight: len(content),
        \ })
endfunction

function! s:HideScrollbar() abort
  if exists('b:scrollbar_popup') && b:scrollbar_popup > 0
    call popup_close(b:scrollbar_popup)
    let b:scrollbar_popup = -1
  endif
endfunction

function s:Clamp(number, min, max)
  if a:number < a:min
    return a:min
  elseif a:number > a:max
    return a:max
  else
    return a:number
  endif
endfunction
