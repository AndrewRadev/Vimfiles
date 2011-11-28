finish

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nosmartindent

" Now, set up our indentation expression and keys that trigger it.
setlocal indentexpr=MyRubyIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,e
setlocal indentkeys+==end,=elsif,=when,=ensure,=rescue,==begin,==end

" Only define the function once.
if exists("*MyRubyIndent")
  finish
endif

let s:indent_callbacks = [
      \ 's:IndentEnd',
      \ 's:IndentScope',
      \ ]

function! MyRubyIndent(lnum)
  for callback in s:indent_callbacks
    call s:PushCursor()

    let indent = call(callback, [a:lnum, getline(a:lnum)])

    if indent < 0
      continue
    else
      return indent
    endif

    call s:PopCursor()
  endfor

  return indent(prevnonblank(a:lnum) - 1)
endfunction

function! s:IndentEnd(lnum, line)
  if a:line =~ '^\s*end\>' && searchpair('\<do\>', '', '\<end\>', 'bW') > 0
    return indent(line('.'))
  else
    return -1
  endif
endfunction

function! s:IndentScope(lnum, line)
  let lnum = prevnonblank(a:lnum - 1)
  let line = getline(lnum)

  if line =~ '\<do\>'
    return indent(lnum) + &sw
  else
    return -1
  endif
endfunction

function! s:PushCursor()
  let b:saved_cursor = getpos('.')
endfunction

function! s:PopCursor()
  call setpos('.', b:saved_cursor)
endfunction
