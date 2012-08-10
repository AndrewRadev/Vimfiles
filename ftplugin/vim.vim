setlocal foldmethod=indent

let b:surround_{char2nr('i')} = "if \1if: \1 \r endif"
let b:surround_{char2nr('w')} = "while \1while: \1 \r endwhile"
let b:surround_{char2nr('f')} = "for \1for: \1 {\r endfor"
let b:surround_{char2nr('e')} = "foreach \1foreach: \1 \r enforeach"
let b:surround_{char2nr('F')} = "function! \1function: \1() \r endfunction"
let b:surround_{char2nr('T')} = "try \r endtry"

let b:outline_pattern = '\<\(function\|command\)\>'

nmap <buffer> gm :exe "help ".expand("<cword>")<cr>

RunCommand so %

setlocal includeexpr=lib#VimIncludeExpression(v:fname)

onoremap <buffer> af :<c-u>call <SID>FunctionTextObject('a')<cr>
xnoremap <buffer> af :<c-u>call <SID>FunctionTextObject('a')<cr>
onoremap <buffer> if :<c-u>call <SID>FunctionTextObject('i')<cr>
xnoremap <buffer> if :<c-u>call <SID>FunctionTextObject('i')<cr>
function! s:FunctionTextObject(mode)
  let function_start = search('^\s*function\>', 'bWnc')
  let function_end   = search('^\s*endfunction\>', 'Wnc')

  if function_start <= 0 || function_end <= 0
    return
  elseif a:mode == 'a'
    if function_start == 1
      " then select whitespace below
      let start = function_start
      let end   = nextnonblank(function_end + 1) - 1
    else
      " select whitespace above
      let start = prevnonblank(function_start - 1) + 1
      let end   = function_end
    endif

    call lib#MarkVisual('V', start, end)
  elseif a:mode == 'i' && (function_end - function_start) > 1
    call lib#MarkVisual('V', function_start + 1, function_end - 1)
  endif
endfunction

if !exists(':Implement')
  command! Implement call s:Implement()
  function! s:Implement()
    if !isdirectory('autoload')
      echomsg 'No "autoload" directory found here.'
    endif

    let saved_iskeyword = &iskeyword
    set iskeyword+=#,:
    let function_name = expand('<cword>')
    let &iskeyword = saved_iskeyword

    if function_name =~ '^s:'
      call s:ImplementScriptLocal(function_name)
    elseif function_name =~ '^\k\+#'
      call s:ImplementAutoloaded(function_name)
    else
      echoerr printf('Don''t know how to implement "%s"', function_name)
    endif
  endfunction

  function! s:ImplementAutoloaded(function_name)
    let function_name = a:function_name
    let parts         = split(function_name, '#')

    call remove(parts, -1)
    if empty(parts)
      echoerr printf('"%s" doesn''t look like an autoloaded function', function_name)
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
    call feedkeys('O')
  endfunction

  function! s:ImplementScriptLocal(function_name)
    let function_name = a:function_name

    call append(line('$'), [
          \ '',
          \ 'function! '.function_name.'()',
          \ 'endfunction',
          \ ])
    normal! G
    call feedkeys('O')
  endfunction
endif
