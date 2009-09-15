" Uses autoload/lib.vim

compiler tidy

" Automatic completion of closing tags
" First, completion function:
function! AutoFinishHtmlTags()
  if &omnifunc == '' || lib#CursorIsInsidePhpMarkup()
    return ''
  else
    return "\<C-x>\<C-o>"
  endif
endfunction
" Map that to '/',
" '>' activates indenting,
" '<bs>' removes the '>'
inoremap <silent> <buffer> / /<C-r>=AutoFinishHtmlTags()<cr>><bs>
