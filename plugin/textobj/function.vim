" textobj-function - Text objects for functions
" Version: 0.1.0
" Copyright (C) 2007-2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
if exists('g:loaded_textobj_function')  "{{{1
  finish
endif








" Interface  "{{{1

call textobj#user#plugin('function', {
\      '-': {
\        '*sfile*': expand('<sfile>:p'),
\        'select-a': 'af',  '*select-a-function*': 's:select_a',
\        'select-i': 'if',  '*select-i-function*': 's:select_i'
\      }
\    })








" Misc.  "{{{1
function! s:select(object_type)
  return exists('b:textobj_function_select')
  \      ? b:textobj_function_select(a:object_type)
  \      : 0
endfunction

function! s:select_a()
  return s:select('a')
endfunction

function! s:select_i()
  return s:select('i')
endfunction








" Fin.  "{{{1

let g:loaded_textobj_function = 1








" __END__
" vim: foldmethod=marker
