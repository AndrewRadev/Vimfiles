if exists(':Prettier')
  command! -buffer Reformat Prettier

  augroup reformat
    autocmd!
    autocmd BufWritePre <buffer> Prettier
  augroup END
endif

let b:outline_pattern = '^\s*\%(export\s*\)\=\%(function\|type\|interface\)\>'
let b:extract_var_template = 'const %s = %s;'
let b:extract_prefix_template = '\%(var\|let\|const\)\s*\zs\k\+\ze\s*='

" TODO (2021-10-11) Types:
" let b:inline_var_pattern = '\%(var\|let\|const\)\s\+\(\k\+\)\s\+=\s\+\(.\{-}\);\='
