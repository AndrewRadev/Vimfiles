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

if &includeexpr == '' " only if not already set
  setlocal includeexpr=PhpIncludeExpr(v:fname)
endif
function! PhpIncludeExpr(fname)
  let line = getline('.')

  " Attempt to detect relative include:
  let fname = lib#ExtractRx(line, '\(require\|include\)\(_once\)\?(\?\s*dirname(__FILE__)\s*\.\s*[''"]\(.\{-}\)[''"]', '\3')
  if fname != line " Then there really is a relative include
    return expand('%:h').fname
  endif

  " Catchall case:
  return a:fname
endfunction
