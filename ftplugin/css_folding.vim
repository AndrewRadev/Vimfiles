" Language:	   One-line folding CSS
" Maintainer:  Michael Wilber <hotdog003@gmail.com>
" Last Change:	2010 Jul 16
" Licence:     BSD license
" Version:     1e-6

function! CssFoldText()
    let line = getline(v:foldstart)
    let nnum = nextnonblank(v:foldstart + 1)
    while nnum < v:foldend+1
        let line = line . " " . substitute(getline(nnum), "^ *", "", "g")
        let nnum = nnum + 1
    endwhile
    return line
endfunction

setlocal foldtext=CssFoldText()
setlocal foldmethod=marker
setlocal foldmarker={,}
setlocal fillchars=fold:\ 
