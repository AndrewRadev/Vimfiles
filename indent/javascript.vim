" Vim indent file
" Language:	JavaScript
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Last Change:  2010-09-05
" Version: 1.0.1

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1
let b:indented = 0
let b:in_comment = 0

setlocal indentexpr=GetJsIndent()
setlocal indentkeys+=0},0),0],0=*/,0=/*
if exists("*GetJsIndent")
    finish
endif

" Check prev line
function! DoIndentPrev(ind,str,v,c)
  let ind = a:ind
  let pline = a:str
  let first = 1
  let last = 0
  while 1
    let last=match(pline, a:v, last)
    if last == -1
      break
    endif
    let str = pline[last]
    let last = last + 1

    " continue until meet '{[('
    if str == a:c
      let first = 0
    endif
    if first != 0
      continue
    endif

    if str == a:c
      let ind = ind + &sw
    else
      let ind = ind - &sw
    endif

  endwhile
  return ind
endfunction

" Check current line
function! DoIndent(ind, str, v, c)
  let ind = a:ind
  let line = a:str
  let last = 0
  let first = 1
  while 1
    let last=match(line, a:v, last)
    if last== -1
      break
    endif
    let str = line[last]
    let last = last + 1

    " break if meet '{[('
    if str == a:c
      break
    endif

    let ind = ind - &sw
  endwhile
  return ind
endfunction

" Remove strings and comments
function! TrimLine(pline)
  let line = substitute(a:pline, "\\\\\\\\", '','g')
  let line = substitute(line, "\\\\.", '','g')
  let nline = line
  while 1
    let dq = match(line,"'")
    let q = match(line,"\"")
    if( (dq<q && dq!=-1) || (dq!=-1 && q==-1))
      let nline = substitute(line, "'[^']*'", '','')
    elseif( (q<dq && q!=-1) || (q!=-1 && dq==-1))
      let nline = substitute(line, '"[^"]*"','','')
    endif
    if(nline==line)
      break
    endif
    let line = nline
  endwhile
  let line = substitute(line, "/\\*.\\{-}\\*/",'','g')
  let line = substitute(line, '//.*$','','')
  let line = substitute(line, "/\\*.*$",'/*','')
  if(b:in_comment)
    let line = substitute(line, "^.*\\*/",'*/','')
  endif
  return line
endfunction


function! GetJsIndent()
    let oline = getline(v:lnum)
    let line = TrimLine(getline(v:lnum))
    if(v:lnum==1)
      let b:is_comment=0
      let pline=''
      let ind = 0
    else
      let pnum = prevnonblank(v:lnum - 1)
      let pline = TrimLine(getline(pnum))
      let ind = indent(pnum)
    endif


    if(b:in_comment==0)
      let items = [ ['[\{\}]','{'], ['[\[\]]','['], ['[\(\)]','('] ]
      for item in items
        let ind = DoIndentPrev(ind, pline, item[0],item[1])
        let ind = DoIndent(ind, line, item[0],item[1])
      endfor
    endif

    if(match(line, "/\\*")!=-1)
      let b:in_comment = 1
    endif

    if(b:in_comment==1)
      if(match(line, "\\*/")!=-1||match(pline, "\\*/")!=-1)
        let b:in_comment = 0
      endif
    endif

    return ind
endfunction
