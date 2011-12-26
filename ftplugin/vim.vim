setlocal foldmethod=indent
set iskeyword-=#

let b:surround_{char2nr('i')} = "if \1if: \1 \r endif"
let b:surround_{char2nr('w')} = "while \1while: \1 \r endwhile"
let b:surround_{char2nr('f')} = "for \1for: \1 {\r endfor"
let b:surround_{char2nr('e')} = "foreach \1foreach: \1 \r enforeach"
let b:surround_{char2nr('F')} = "function! \1function: \1() \r endfunction"

let b:outline_pattern = '\<\(function\|command\)\>'

nmap <buffer> gm :exe "help ".expand("<cword>")<cr>

RunCommand so %

setlocal includeexpr=lib#VimIncludeExpression(v:fname)

if !exists(':Implement')
  command! Implement call s:Implement()
  function! s:Implement()
    if !isdirectory('autoload')
      echomsg 'No "autoload" directory found here.'
    endif

    let saved_iskeyword = &iskeyword
    set iskeyword+=#
    let function_name = expand('<cword>')
    let &iskeyword = saved_iskeyword

    let parts = split(function_name, '#')
    call remove(parts, -1)
    if empty(parts)
      echomsg printf('"%s" doesn''t look like an autoloaded function', function_name)
    endif

    let path = printf('autoload/%s.vim', join(parts, '/'))
    let dir  = fnamemodify(path, ':p:h')
    if !isdirectory(dir)
      mkdir(dir, 'p')
    endif

    if fnamemodify(path, ':p') != expand('%:p')
      exe 'split '.path
    endif

    call append(line('$'), [
          \ '',
          \ 'function! '.function_name.'()',
          \ 'endfunction',
          \ ])
    normal! G
  endfunction
endif
