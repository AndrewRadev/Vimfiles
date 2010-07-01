if !exists('*g:textobj_comment_vim_select')
  function! g:textobj_comment_vim_select(object_type_unused)
    let current = line('.')

    " check if we are in a comment at all:
    if getline(current) !~ '\s*"'
      return 0
    endif

    " find the first non-comment line upwards:
    while current > 0 && getline(current - 1) =~ '\s*"'
      let current = current - 1
    endwhile

    let b = [0, current, 0, 0]

    " find the first non-comment line downwards:
    let final = line('$')
    while current < final && getline(current + 1) =~ '\s*"'
      let current = current + 1
    endwhile

    let e = [0, current, 0, 0]

    return ['V', b, e]
  endfunction
endif

let b:textobj_comment_select = function('g:textobj_comment_vim_select')

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= '|'
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin .= 'unlet b:textobj_comment_select'
