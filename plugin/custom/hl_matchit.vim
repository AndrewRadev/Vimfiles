if !exists('g:hl_matchit_syntax_group')
  let g:hl_matchit_syntax_group = 'Search'
endif

if !exists('g:hl_matchit_no_mapping')
  nnoremap <Leader>% :HlMatchit<cr>
endif

command! HlMatchit call lib#MarkMatches(g:hl_matchit_syntax_group)
command! Noh noh | call clearmatches()
