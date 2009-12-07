" File: lib.vim
" Author: Andrew Radev
" Description: The place for any functions I might decide I need.
" Last Modified: December 06, 2009

" Function to check if the cursor is currently in a php block. Useful for
" autocompletion. Ripped directly from phpcomplete.vim
function! lib#CursorIsInsidePhpMarkup()
  let phpbegin = searchpairpos('<?', '', '?>', 'bWn',
      \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\|comment"')
  let phpend   = searchpairpos('<?', '', '?>', 'Wn',
      \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\|comment"')
  return !(phpbegin == [0,0] && phpend == [0,0])
endfunction

" Toggle between settings:
function! lib#MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
endfunction

" Capitalize first letter of argument:
" word -> Word
function! lib#Capitalize(word)
  return substitute(a:word, '^\w', '\U\0', 'g')
endfunction

" Encode the given string for use as part of an url
" Ripped directly from haskellmode.vim
function! lib#UrlEncode(string)
  let pat  = '\([^[:alnum:]]\)'
  let code = '\=printf("%%%02X",char2nr(submatch(1)))'
  let url  = substitute(a:string,pat,code,'g')
  return url
endfunction
