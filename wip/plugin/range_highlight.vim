finish

augroup range_highlight
  autocmd!

  autocmd CmdlineChanged : call s:RangeHighlight()
  autocmd CmdlineLeave : call s:RangeClear()
augroup END

let s:match_id = 0

function! s:RangeHighlight() abort
  let command_line = getcmdline()
  let start_line   = 0
  let end_line     = 0

  let two_lines_pattern   = '^\(\d\+\),\(\d\+\)'
  let single_line_pattern = '^\d\+'

  if command_line =~ two_lines_pattern
    let [_match, first, second; _rest] = matchlist(command_line, two_lines_pattern)
    let start_line = str2nr(first)
    let end_line = str2nr(second)
  elseif command_line =~ single_line_pattern
    let start_line = str2nr(matchstr(command_line, single_line_pattern))
    let end_line = start_line
  endif

  if start_line > 0 && end_line > 0 && start_line <= end_line
    call s:RangeClear()
    let s:match_id = matchadd('Visual', '\%' .. start_line .. 'l\_.*\%' .. end_line .. 'l')
    redraw
  endif
endfunction

function! s:RangeClear() abort
  if s:match_id > 0
    call matchdelete(s:match_id)
    let s:match_id = 0
  endif
endfunction
