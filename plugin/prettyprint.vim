" Prettyprint vim variables.
" Version: 0.3.0
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

if exists('g:loaded_prettyprint') || v:version < 702
  finish
endif
let g:loaded_prettyprint = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:pp(expr, shift, width, stack)
  let indent = repeat(s:blank, a:shift)
  let indentn = indent . s:blank

  let appear = index(a:stack, a:expr)
  call add(a:stack, a:expr)

  let width = s:width - a:width - s:indent * a:shift


  let str = ''
  if type(a:expr) == type([])
    if appear < 0
      let result = []
      for Expr in a:expr
        call add(result, s:pp(Expr, a:shift + 1, 0, a:stack))
        unlet Expr
      endfor
      let oneline = '[' . join(result, ', ') . ']'
      if strlen(oneline) < width && oneline !~ "\n"
        let str = oneline
      else
        let content = join(map(result, 'indentn . v:val'), ",\n")
        let str = printf("[\n%s\n%s]", content, indent)
      endif
    else
      let str = '[nested element ' . appear .']'
    endif

  elseif type(a:expr) == type({})
    if appear < 0
      let result = []
      for key in sort(keys(a:expr))
        let skey = string(strtrans(key))
        let sep = ': '
        let value = s:pp(a:expr[key], a:shift + 1, strlen(skey . sep), a:stack)
        if s:indent < strlen(skey . sep) &&
        \ width - s:indent < strlen(skey . sep . value) && value !~ "\n"
          let sep = ":\n" . indentn . s:blank
        endif
        call add(result, skey . sep . value)
        unlet value
      endfor
      let oneline = '{' . join(result, ', ') . '}'
      if strlen(oneline) < width && oneline !~ "\n"
        let str = oneline
      else
        let content = join(map(result, 'indentn . v:val'), ",\n")
        let str = printf("{\n%s\n%s}", content, indent)
      endif
    else
      let str = '{nested element ' . appear .'}'
    endif

  else
    if &verbose && type(a:expr) == type(function('tr'))
      redir => func
      " Don't print a definition location if &verbose == 1.
      silent! execute (&verbose - 1) 'verbose function a:expr'
      redir END
      let str = func
    elseif type(a:expr) == type('')
      let str = string(strtrans(a:expr))
    else
      let str = string(a:expr)
    endif
  endif

  unlet a:stack[-1]
  return str
endfunction

function! PrettyPrint(...)
  let s:indent = type(g:prettyprint_indent) == type('') ?
  \              eval(g:prettyprint_indent) : g:prettyprint_indent
  let s:blank = repeat(' ', s:indent)
  let s:width = ( type(g:prettyprint_width) == type('') ?
  \               eval(g:prettyprint_width) : g:prettyprint_width ) - 1
  let result = []
  for Expr in a:000
    call add(result, s:pp(Expr, 0, 0, []))
    unlet Expr
  endfor
  return join(result, "\n")
endfunction

function! PP(...)
  return call('PrettyPrint', a:000)
endfunction

if !exists('g:prettyprint_indent')
  let g:prettyprint_indent = '&l:shiftwidth'
endif

if !exists('g:prettyprint_width')
  let g:prettyprint_width = '&columns'
endif

command! -nargs=+ -complete=expression PrettyPrint echo PrettyPrint(<args>)
command! -nargs=+ -complete=expression PP echo PP(<args>)

let &cpo = s:save_cpo
unlet s:save_cpo
