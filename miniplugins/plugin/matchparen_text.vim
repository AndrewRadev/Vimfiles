" Original idea: https://github.com/briangwaltney/paren-hint.nvim
"
" Requires the built-in matchparen plugin to be activated

if exists("g:loaded_matchparen_text") || &cp
  finish
endif
let g:loaded_matchparen_text = 1

" List of autocommands copied from matchparen plugin
augroup paren_hint
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

  if empty(prop_type_get('paren_hint', {'bufnr': bufnr('%')}))
    call prop_type_add('paren_hint', {
          \ 'bufnr':     bufnr('%'),
          \ 'highlight': 'Comment',
          \ 'combine':   v:true
          \ })
  endif

  call s:RemoveText()

  for m in getmatches()
    if m.group != 'MatchParen'
      " not a highlight we're interested in
      continue
    endif

    if m.pos1[0] <= m.pos2[0]
      " if equal, it's the same line, we don't need the context
      " if pos1 > pos2, we're on the opening bracket and we can see the text
      continue
    endif

    let start_pos = m.pos2
    let end_pos   = m.pos1

    let text = trim(strpart(getline(start_pos[0]), 0, start_pos[1] - 1))

    call prop_add(end_pos[0], len(getline(end_pos[0])) + 1, {
          \ 'type': 'paren_hint',
          \ 'text': ' ' .. text,
          \ })
  endfor
endfunction

function! s:RemoveText() abort
  if !empty(prop_type_get('paren_hint', {'bufnr': bufnr('%')}))
    call prop_remove({'type': 'paren_hint', 'all': v:true})
  endif
endfunction
