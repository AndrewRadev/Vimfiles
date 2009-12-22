let php_htmlInStrings = 1
let php_baselib       = 1
let php_folding       = 1

" Look up the word under the cursor on php.net:
nmap <buffer> gm :exe ":Utl ol http://php.net/manual-lookup.php?pattern=" . expand("<cword>")<cr>

command! -buffer Outline call Outline()
function! Outline()
  if exists('b:outlined') " Un-outline it 
    FoldEndFolding
    unlet b:outlined
  else
    FoldMatching function -1
    let b:outlined = 1
  endif
endfunction
