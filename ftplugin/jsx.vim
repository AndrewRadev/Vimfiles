set includeexpr=<SID>Includeexpr()

augroup jsx_autocommands
  autocmd!

  " Override gf if rails sets it after
  autocmd User Rails cmap <buffer><expr> <Plug><cfile> <SID>Includeexpr()
augroup END

function! s:Includeexpr()
  let word = expand('<cword>')
  let pattern = '^\s*import\s\+'.word.'\s\+from\s\+\zs[''"]\(.\{-}\)[''"]'

  if search(pattern, 'wc') <= 0
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
    if filereadable(absolute_path.suffix)
      return absolute_path.suffix
    endif
  endfor

  return relative_path
endfunction
