if exists('g:loaded_textobj_comment')
  finish
endif

call textobj#user#plugin('comment', {
      \      'comment': {
      \        '*sfile*': expand('<sfile>:p'),
      \        'select-a': 'ac',  '*select-a-function*': 's:select_a',
      \        'select-i': 'ic',  '*select-i-function*': 's:select_i'
      \      }
      \    })

function! s:select(object_type)
  return exists('b:textobj_comment_select')
        \      ? b:textobj_comment_select(a:object_type)
        \      : 0
endfunction

function! s:select_a()
  return s:select('a')
endfunction

function! s:select_i()
  return s:select('i')
endfunction

let g:loaded_textobj_comment = 1
