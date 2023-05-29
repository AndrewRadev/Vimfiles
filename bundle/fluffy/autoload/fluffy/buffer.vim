function! fluffy#buffer#New() abort
  return #{
        \   paths:         [],
        \   start_time:    reltime(),
        \   duration:      0,
        \   loading:       ['⢿', '⣻', '⣽', '⣾', '⣷', '⣯', '⣟', '⡿'],
        \   loading_index: 0,
        \   finished:      0,
        \
        \   Update:     function('s:Update'),
        \   Statusline: function('s:Statusline'),
        \ }
endfunction

function! s:Update(params) dict abort
  let new_paths = get(a:params, 'new_paths', [])
  let finished  = get(a:params, 'finished', self.finished)

  call extend(self.paths, new_paths)

  if finished
    let self.finished = 1
    let self.duration = reltimefloat(reltime(self.start_time))
  else
    let self.loading_index += 1
    let self.loading_index %= len(self.loading)
  endif

  if line('$') > 1
    silent 1,$-1delete _
  endif
  syn clear

  let query = matchstr(getline('.'), '^> \zs.*')
  let query = substitute(query, '\s\+', '', 'g')

  if len(query) == 0
    let file_count = min([winheight(0) - 1, len(self.paths)])

    for i in range(file_count)
      call append(line('$') - 1, self.paths[i])
    endfor
  endif

  let results = []
  let [paths, char_positions, scores] =
        \ matchfuzzypos(self.paths, query, { 'matchseq': g:fluffy_matchseq })
  let limit = min([winheight(0) - 1, len(paths)])

  for i in range(limit)
    let path = paths[i]
    let score = scores[i]
    let indexes = map(char_positions[i], { _, pos -> byteidx(path, pos) })

    call append(line('$') - 1, path)

    if g:fluffy_show_score
      call prop_add(line('$') - 1, 0, {
            \ 'type': 'score_text',
            \ 'text': score,
            \ 'text_padding_left': 1
            \ })
    endif

    for index in indexes
      exe 'syn match fluffyMatch /\%' .. (line('$') - 1) .. 'l\%' .. (index + 1).. 'c./'
    endfor
  endfor

  set nomodified
  normal! Gzb
  startinsert!
endfunction

function s:Statusline() dict abort
  if self.finished
    return $"Loaded {len(self.paths)} files in {self.duration}s"
  else
    return $"Loading {self.loading[self.loading_index]} ({len(self.paths)} files)"
  endif
endfunction
