set includeexpr=<SID>Includeexpr()

augroup jsx_autocommands
  autocmd!

  " Override gf if rails sets it after
  autocmd User Rails cmap <buffer><expr> <Plug><cfile> <SID>Includeexpr()
augroup END

function! s:Includeexpr()
  let word = expand('<cword>')

  let import_pattern =
        \ '^\s*import\s\+\%({\%(\w\|,\s*\)*\)\='.
        \ word.
        \ '\%(\%(\w\|,\|\s*\)*}\)\=\s\+from\s\+\zs[''"]\(.\{-}\)[''"]'

  if search(import_pattern, 'wc') <= 0
    return word
  endif

  let start_quote_col = col('.')
  let quote = getline('.')[start_quote_col - 1]

  if search(quote, 'W', line('.')) <= 0
    return word
  endif
  let end_quote_col = col('.')

  let relative_path = strpart(getline('.'), start_quote_col, (end_quote_col - start_quote_col - 1))
  let dirname = expand('%:h')

  let absolute_path = fnamemodify(dirname.'/'.relative_path, ':p')
  let suffixes = ['.js', '.jsx', '/index.js', '/index.jsx']

  for suffix in suffixes
    let path = substitute(absolute_path, '/$', '', '').suffix

    if filereadable(path)
      return simplify(fnamemodify(path, ':.'))
    endif
  endfor

  return relative_path
endfunction
