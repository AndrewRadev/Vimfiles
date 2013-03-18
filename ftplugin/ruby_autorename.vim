autocmd BufWritePost <buffer> call s:CheckForClassRename()

" TODO (2013-02-10) Use InsertEnter for cases of i,a, etc.?
" TODO (2013-02-10) Use mappings for cases of i,a, etc.?

function! s:CheckForClassRename()
  let current_line  = getline('.')
  let filename      = expand('%:t')
  let base_filename = expand('%:t:r')
  let extension     = expand('%:t:e')
  let dirname       = expand('%:h')
  let class_name    = lib#CapitalCamelCase(base_filename)
  let class_pattern = '^\s*class\s\+\(\w\+\).*$'

  if @" =~ class_name && current_line =~ class_pattern
    let new_class_name = substitute(current_line, class_pattern, '\1', '')
    let new_filename   = lib#Underscore(new_class_name).'.'.extension

    if s:Ask('Rename to "'.new_filename.'"?')
      exe 'saveas '.dirname.'/'.new_filename
      call delete(dirname.'/'.filename)
    endif
  endif
endfunction

function! s:Ask(text)
  echo a:text.' (yN):'
  let choice = nr2char(getchar())
  return (choice ==# 'y')
endfunction
