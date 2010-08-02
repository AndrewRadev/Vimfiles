" Note: relies on the matchit plugin to work properly.

if !exists('*g:textobj_function_ruby_select')
  function! g:textobj_function_ruby_select(object_type)
    return s:select_{a:object_type}()
  endfunction

  function! s:select_a()
    if search('def', 'bcW') == 0
      return 0
    endif

    let b = getpos('.')

    normal %

    let e = getpos('.')

    if 1 < e[1] - b[1]  " is there some code?
      return ['V', b, e]
    else
      return 0
    endif
  endfunction

  function! s:select_i()
    if search('def', 'bcW') == 0
      return 0
    endif

    let b = getpos('.')

    normal %

    let e = getpos('.')

    if 1 < e[1] - b[1]  " is there some code?
      call setpos('.', b)
      normal! j
      let b = getpos('.')
      call setpos('.', e)
      normal! k
      let e = getpos('.')
      return ['V', b, e]
    else
      return 0
    endif
  endfunction
endif

let b:textobj_function_select = function('g:textobj_function_ruby_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_function_select'

" __END__
" vim: foldmethod=marker
