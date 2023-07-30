" autoload/put_at_end.vim

function! put_at_end#Mapping(string) abort
  let saved_view = winsaveview()
  defer winrestview(saved_view)
  defer s:Repeat(a:string)

  if &commentstring == ''
    exe 'normal! A' .. a:string
    return
  endif

  if &commentstring == '/*%s*/'
    let comment_regex = '//.*'
  else
    let comment_regex = substitute(&commentstring, '%s', '.*', '')
  endif

  call search('\S\s*\%(' .. comment_regex .. '\)\=$', 'Wc', line('.'))
  let prefix = strpart(getline('.'), 0, col('.'))

  if prefix !~# '\V'.escape(a:string, '\').'\m$'
    exe 'normal! a' .. a:string
  endif
endfunction

function! s:Repeat(string)
  let mapping = ":silent call put_at_end#Mapping('" .. escape(a:string, "'") .. "')\<cr>"
  silent! call repeat#set(mapping)
endfunction

" To set up specific mappings, invoke the function with a string to append:
"
" nnoremap <silent> z, :call put_at_end#Mapping(',')<cr>
" nnoremap <silent> z; :call put_at_end#Mapping(';')<cr>
" nnoremap <silent> z) :call put_at_end#Mapping('),')<cr>
"
" If you have repeat.vim installed, you can repeat the append with a .
