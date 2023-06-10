hi def link fuzzyMatch Search
hi def link fuzzyScore TODO

command! Fuzzy call s:Fuzzy(<q-mods>)

function! s:Fuzzy(mods)
  if !executable('rg')
    echoerr ":Fuzzy requires ripgrep (the `rg` executable)"
    return
  endif

  exe a:mods .. ' new'
  set buftype=prompt
  setlocal statusline=%{b:statusline}

  let b:statusline = ''
  let b:all_paths = []
  let b:start_time = reltime()
  let b:last_update = reltime()
  let b:duration = 0
  let b:loading = ['⢿', '⣻', '⣽', '⣾', '⣷', '⣯', '⣟', '⡿']
  let b:loading_index = 0

  let b:job = job_start('rg --files', #{
        \ out_cb: function('s:AddPath'),
        \ exit_cb: function('s:Finish'),
        \ })

  call prompt_setcallback(bufnr(), function('s:TextEntered'))
  call prompt_setprompt(bufnr(), "> ")
  call prop_type_add('score_text', { 'bufnr': bufnr(), 'highlight': 'fuzzyScore' })

  startinsert

  autocmd TextChangedI,TextChangedP <buffer> call s:UpdateBuffer()
  autocmd QuitPre <buffer> call job_stop(b:job)

  inoremap <buffer> <c-c> <esc>:quit!<cr>
  inoremap <buffer> <c-d> <esc>:quit!<cr>
endfunction

function! s:UpdateBuffer()
  if line('$') > 1
    1,$-1delete _
  endif
  syn clear

  let query = matchstr(getline('.'), '^> \zs.*')
  let query = substitute(query, '\s\+', '', 'g')

  if len(query) == 0
    let file_count = min([winheight(0) - 1, len(b:all_paths)])

    for i in range(file_count)
      call append(line('$') - 1, b:all_paths[i])
    endfor
  endif

  let results = []
  let [paths, char_positions, scores] =
        \ matchfuzzypos(b:all_paths, query, { 'matchseq': 1 })
  let limit = min([winheight(0) - 1, len(paths)])

  for i in range(limit)
    let path = paths[i]
    let score = scores[i]
    let indexes = map(char_positions[i], { _, pos -> byteidx(path, pos) })

    call append(line('$') - 1, path)
    call prop_add(line('$') - 1, 0, {
          \ 'type': 'score_text',
          \ 'text': score,
          \ 'text_padding_left': 1
          \ })

    for index in indexes
      exe 'syn match fuzzyMatch /\%' .. (line('$') - 1) .. 'l\%' .. (index + 1).. 'c./'
    endfor
  endfor

  set nomodified
  normal! Gzb
  startinsert!
endfunction

function! s:TextEntered(_text)
  if line('$') <= 2
    quit
  elseif filereadable(getline(1))
    exe 'edit ' .. getline(1)
  else
    quit
  endif
endfunc

function! s:AddPath(_job, line)
  call add(b:all_paths, a:line)

  if reltimefloat(reltime(b:last_update)) > 0.1
    let b:statusline = $"Loading {b:loading[b:loading_index]} ({len(b:all_paths)} files)"

    let b:loading_index += 1
    let b:loading_index %= len(b:loading)

    let b:last_update = reltime()
    call s:UpdateBuffer()
  endif
endfunction

function! s:Finish(_job, status)
  if !exists('b:duration')
    return
  endif

  let b:duration = reltimefloat(reltime(b:start_time))
  let b:statusline = $"Loaded {len(b:all_paths)} files in {b:duration}s"
  call s:UpdateBuffer()
endfunction
