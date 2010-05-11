" Vim indent file
" Language: YAML
" Author: Andrew Radev
" Last Modified: December 02, 2009

if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

setlocal indentexpr=GetYamlIndent()
setlocal indentkeys=o,O

function! GetYamlIndent()
  let prev_line = getline(v:lnum - 1) " last line
  let ind       = indent(v:lnum - 1)

  if prev_line =~ ':\s*$' || prev_line =~ ':\s*[|>]\s*$'
    return ind + &sw
  else
    return ind
  endif
endfunction
