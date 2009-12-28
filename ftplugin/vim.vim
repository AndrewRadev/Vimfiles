setlocal foldmethod=indent

" For <C-]> to be able to detect:
" - autoloaded functions
" - mappings, 
" - variables with a scope prefix
setlocal iskeyword+=:,#,<,>

command! -buffer Outline call lib#Outline('\<function\>')
