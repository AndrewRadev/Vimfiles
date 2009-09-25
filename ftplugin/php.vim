let php_htmlInStrings = 1
let php_baselib = 1
let php_folding = 1

if !exists("b:current_compiler")
  compiler php
endif

nmap <buffer> gm :exe ":Utl ol http://php.net/manual-lookup.php?pattern=" . expand("<cword>")<cr>
