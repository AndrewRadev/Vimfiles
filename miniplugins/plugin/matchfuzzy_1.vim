" Note: Educational, will likely be removed

hi def link fuzzyMatch Search

command! Fuzzy1 call s:FuzzyFindFile()

function! s:TextEntered(_text) abort
  if line('$') <= 2
    quit
  else
    exe 'edit ' .. getline(1)
  endif
endfunc

function! s:FuzzyFindFile() abort
  new
  set buftype=prompt

  let b:all_paths = glob('**/*', 0, 1)
  call prompt_setcallback(bufnr(), function('s:TextEntered'))
  call prompt_setprompt(bufnr(), "> ")

  startinsert

  autocmd TextChangedI <buffer> call s:UpdateBuffer()
endfunction

function! s:UpdateBuffer() abort
  if line('$') > 1
    1,$-1delete _
  endif
  syn clear

  let query = matchstr(getline('.'), '^> \zs.*')
  let query = substitute(query, '\s\+', '', 'g')

  let results = []
  let [paths, char_positions, scores] =
        \ matchfuzzypos(b:all_paths, query, { 'limit': winheight(0) - 1, 'matchseq': 1 })
  for i in range(len(paths))
    let path = paths[i]
    let score = scores[i]
    let indexes = map(char_positions[i], { _, pos -> byteidx(path, pos) })

    call append(line('$') - 1, path)

    for index in indexes
      exe 'syn match fuzzyMatch /\%' .. (line('$') - 1) .. 'l\%' .. (index + 1).. 'c./'
    endfor
  endfor

  set nomodified
  normal! Gzb
  startinsert!
endfunction
