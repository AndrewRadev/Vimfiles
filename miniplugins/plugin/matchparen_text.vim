" Original idea: https://github.com/briangwaltney/paren-hint.nvim
"
" Requires the built-in matchparen plugin to be activated

if exists("g:loaded_matchparen_text") || &cp
  finish
endif
let g:loaded_matchparen_text = 1

if empty(prop_type_get('matchparen_text'))
  call prop_type_add('matchparen_text', {
        \ 'highlight': 'Comment',
        \ 'combine':   v:true
        \ })
endif

" List of autocommands copied from matchparen plugin
augroup matchparen_text
  autocmd! CursorMoved,CursorMovedI,WinEnter,BufWinEnter,WinScrolled * call s:AddText()
  autocmd! WinLeave,BufLeave * call s:RemoveText()
  if exists('##TextChanged')
    autocmd! TextChanged,TextChangedI * call s:AddText()
    autocmd! TextChangedP * call s:RemoveText()
  endif
augroup END

function! s:AddText() abort
  if !exists(':DoMatchParen')
    return
  endif

  call s:RemoveText()

  for m in getmatches()
    if m.group != 'MatchParen'
      " not a highlight we're interested in
      continue
    endif

    if m.pos1[0] <= m.pos2[0]
      " if equal, it's the same line, we don't need the context
      "
      " if pos1 < pos2, we're currently on the opening bracket, so we don't
      " need to see the opening text
      continue
    endif

    let start_pos = m.pos2
    let end_pos   = m.pos1

    let text = trim(strpart(getline(start_pos[0]), 0, start_pos[1] - 1))

    call prop_add(end_pos[0], len(getline(end_pos[0])) + 1, {
          \ 'type': 'matchparen_text',
          \ 'text': ' ' .. text,
          \ })
  endfor
endfunction

function! s:RemoveText() abort
  call prop_remove({'type': 'matchparen_text', 'all': v:true})
endfunction
