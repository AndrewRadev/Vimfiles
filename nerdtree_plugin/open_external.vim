if exists('g:open_external_loaded')
  finish
endif
let g:open_external_loaded = 1

call NERDTreeAddKeyMap({
      \ 'key': 'gu',
      \ 'callback': 'OpenCurrentNode',
      \ 'quickhelpText': 'open current node with the Utl plugin' })

function! OpenCurrentNode()
  silent call Utl('openLink', GetNERDTreePath())
  redraw!
endfunction

" Function to extract the path currently under the cursor in the NERDTree and
" open it using the Utl plugin.
"
" Requires: Utl, NERD_Tree
function! GetNERDTreePath()
  let result = g:NERDTreeFileNode.GetSelected().path.str()
  let result = substitute( result, '\', '/', 'g' )
  let result = substitute( result, ' ', '%20', 'g' )
  return 'file://' . result
endfunction
