let php_htmlInStrings      = 1
let php_baselib            = 1
let php_folding            = 0 " Custom plugin for that
let php_noShortTags        = 1
let php_parent_error_close = 1
let php_sync_method        = 0

let b:surround_{char2nr('-')} = "<?php \r ?>"
let b:surround_{char2nr('=')} = "<?php echo \r ?>"
" surround area with <foo> (...) { }
let b:surround_{char2nr('i')} = "if (\1if: \1) {\r}"
let b:surround_{char2nr('w')} = "while (\1while: \1) {\r}"
let b:surround_{char2nr('f')} = "for (\1for: \1) {\r}"
let b:surround_{char2nr('e')} = "foreach (\1foreach: \1) {\r}"
" surround area with <?php <foo> (...): ?> <?php end<foo> ?>
let b:surround_{char2nr('I')} = "<?php if (\1if: \1): ?>\r<?php endif ?>"
let b:surround_{char2nr('W')} = "<?php while (\1while: \1): ?>\r<?php endwhile ?>"
let b:surround_{char2nr('F')} = "<?php for (\1for: \1): ?>\r<?php endfor ?>"
let b:surround_{char2nr('E')} = "<?php foreach (\1foreach: \1): ?>\r<?php endforeach ?>"

" Look up the word under the cursor on php.net:
nmap <buffer> gm :call Open('http://php.net/manual-lookup.php?pattern=' . expand("<cword>"))<cr>

let b:outline_pattern = '\<function\>'

if &includeexpr == '' " only if not already set
  setlocal includeexpr=PhpIncludeExpr(v:fname)
endif
function! PhpIncludeExpr(fname)
  let line = getline('.')

  " Attempt to detect relative include:
  let fname = lib#ExtractRx(line, '\(require\|include\)\(_once\)\?(\?\s*dirname(__FILE__)\s*\.\s*[''"]\(.\{-}\)[''"]', '\3')
  if fname != line " Then there really is a relative include
    return expand('%:p:.:h').fname
  endif

  " Catchall case:
  return a:fname
endfunction

RunCommand !php % <args>

" Define a text object for php segments (<?php ... ?>)
onoremap <buffer> a= :<c-u>call <SID>PhpTextObject('a')<cr>
xnoremap <buffer> a= :<c-u>call <SID>PhpTextObject('a')<cr>
onoremap <buffer> i= :<c-u>call <SID>PhpTextObject('i')<cr>
xnoremap <buffer> i= :<c-u>call <SID>PhpTextObject('i')<cr>
function! s:PhpTextObject(mode)
  if sj#SearchUnderCursor('<?\%(php\)\?.\{-}?>', '') <= 0
    return
  endif

  if a:mode == 'i'
    call search('<?\%(php\)\?\s*\S', 'e', line('.'))
  endif
  let start = virtcol('.')

  if a:mode == 'i'
    let end_flags = ''
  else
    let end_flags = 'e'
  endif

  call search('\S\s*-\??>', end_flags, line('.'))
  let end = virtcol('.')

  if start == 0
    exe 'normal! 0v'.end.'|'
  else
    exe 'normal! 0'.start.'|v'.end.'|'
  endif
endfunction
