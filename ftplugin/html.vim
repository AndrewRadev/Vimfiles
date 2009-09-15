compiler tidy

" Automatic completion of closing tags
" First, completion function:
function! AutoFinishTags()
  let completion_start = htmlcomplete#CompleteTags(1, '')
  call complete( col('.'), htmlcomplete#CompleteTags(0, '') )
  return ''
endfunction
" Map that to '/',
" '>' activates indenting,
" '<bs>' removes the '>'
inoremap / /<C-r>=AutoFinishTags()<cr>><bs>
