let php_htmlInStrings = 1
let php_baselib       = 1
let php_folding       = 1

" Look up the word under the cursor on php.net:
nmap <buffer> gm :exe ":Utl ol http://php.net/manual-lookup.php?pattern=" . expand("<cword>")<cr>

setlocal complete=t " Only search in tagfiles
