" File: lib.vim
" Author: Andrew Radev
" Description: The place for any functions I might decide I need.
" Last Modified: October 04, 2009

" Function to check if the cursor is currently in a php block. Useful for
" autocompletion. Ripped directly from phpcomplete.vim
function! lib#CursorIsInsidePhpMarkup()
  let phpbegin = searchpairpos('<?', '', '?>', 'bWn',
      \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\|comment"')
  let phpend   = searchpairpos('<?', '', '?>', 'Wn',
      \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\|comment"')
  return !(phpbegin == [0,0] && phpend == [0,0])
endfunction

" Function to extract the path currently under the cursor in the NERDTree and
" open it using the Utl plugin.
"
" Requires: Utl, NERD_Tree
function! lib#GetNERDTreePath()
  let current_path = NERDTreeGetCurrentPath()

  if empty( current_path )
    throw "Invalid path"
  endif

  let result = current_path.strForOS(0)
  let result = substitute( result, '\', '/', 'g' )
  let result = substitute( result, ' ', '%20', 'g' )
  return result
endfunction

" Function to Align ranged text on whitespace -- by columns:
"
" Requires: Align
function! lib#AlignSpace() range
  AlignPush
  AlignCtrl lp0P0
  execute a:firstline.','.a:lastline.'Align \s\S'
  AlignPop
endfunction

" Function to toggle between settings:
function! lib#MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
endfunction
