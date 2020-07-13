"
" All of the variables below are from vim-ruby's indent script
"
" Syntax group names that are strings.
let s:syng_string =
      \ ['String', 'Interpolation', 'InterpolationDelimiter', 'StringEscape']
" Syntax group names that are strings or documentation.
let s:syng_stringdoc = s:syng_string + ['Documentation']
" Syntax group names that are or delimit strings/symbols/regexes or are comments.
let s:syng_strcom = s:syng_stringdoc + [
      \ 'Character',
      \ 'Comment',
      \ 'HeredocDelimiter',
      \ 'PercentRegexpDelimiter',
      \ 'PercentStringDelimiter',
      \ 'PercentSymbolDelimiter',
      \ 'Regexp',
      \ 'RegexpCharClass',
      \ 'RegexpDelimiter',
      \ 'RegexpEscape',
      \ 'StringDelimiter',
      \ 'Symbol',
      \ 'SymbolDelimiter',
      \ ]

" Expression used to check whether we should skip a match with searchpair().
let s:skip_expr =
      \ 'index(map('.string(s:syng_strcom).',"hlID(''ruby''.v:val)"), synID(line("."),col("."),1)) >= 0'

" Regex that defines the start-match for the 'end' keyword.
let s:end_start_regex =
      \ '\C\%(^\s*\|[=,*/%+\-|;{]\|<<\|>>\|:\s\)\s*\zs' .
      \ '\<\%(module\|class\|if\|for\|while\|until\|case\|unless\|begin' .
      \   '\|\%(\K\k*[!?]\?\s\+\)\=def\):\@!\>' .
      \ '\|\%(^\|[^.:@$]\)\@<=\<do:\@!\>'
" Regex that defines the end-match for the 'end' keyword.
let s:end_end_regex = '\%(^\|[^.:@$]\)\@<=\<end:\@!\>'

" Regex that defines blocks.
let s:block_regex =
      \ '\%(\<do:\@!\>\|%\@<!{\)\s*\%(|[^|]*|\)\=\s*\%(#.*\)\=$'

onoremap <silent> <buffer> ar :<c-u>call <SID>RubyBlock('a', v:false)<cr>
xnoremap <silent> <buffer> ar :<c-u>call <SID>RubyBlock('a', v:true)<cr>
onoremap <silent> <buffer> ir :<c-u>call <SID>RubyBlock('i', v:false)<cr>
xnoremap <silent> <buffer> ir :<c-u>call <SID>RubyBlock('i', v:true)<cr>

function! s:RubyBlock(mode, visual)
  let saved_z_pos = getpos("'z")
  let saved_view = winsaveview()

  if a:visual
    let visual_mapping = visualmode()
  else
    let visual_mapping = 'V'
  endif

  try
    if search(s:block_regex, 'Wbc', 0, 0, s:skip_expr) <= 0
      call winrestview(saved_view)
      return
    endif
    let start_line = line('.')

    if a:mode == 'i'
      let saved_pos = getpos('.')
      normal! j^
      call setpos("'z", getpos('.'))
      call setpos('.', saved_pos)
    else
      call setpos("'z", getpos('.'))
    endif

    if searchpair(s:end_start_regex, '', s:end_end_regex, 'W', s:skip_expr) <= 0
      call winrestview(saved_view)
      return
    endif
    " jump to the end of the match
    call search(s:end_end_regex, 'We', line('.'))

    if a:mode == 'i'
      normal! kg_
    endif

    if line('.') < getpos("'z")[1]
      " then the current line is the start line, or above it, nothing to
      " select
      return
    endif

    exe 'normal! '. visual_mapping . '`z'
  finally
    call setpos("'z", saved_z_pos)
  endtry
endfunction
