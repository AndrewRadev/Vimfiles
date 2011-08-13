if exists("g:loaded_nerdree_diff_mapping")
  finish
endif
let g:loaded_nerdree_diff_mapping = 1

call NERDTreeAddKeyMap({
      \ 'key':           'D',
      \ 'callback':      'NERDTreeDiffWithLastBuffer',
      \ 'quickhelpText': 'open file and diff it against the last buffer',
      \ })

function! NERDTreeDiffWithLastBuffer()
  let current_node = g:NERDTreeFileNode.GetSelected()

  if current_node == {}
    return
  else
    wincmd w
    diffthis
    exe "vsplit ".fnameescape(current_node.path.str())
    diffthis
  endif
endfunction
