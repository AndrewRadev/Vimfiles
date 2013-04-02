if exists("g:loaded_nerdree_external_open_mapping")
  finish
endif
let g:loaded_nerdree_external_open_mapping = 1

call NERDTreeAddKeyMap({
      \ 'key':           'gu',
      \ 'callback':      'NERDTreeOpenCurrentNodeWithExternalAssociation',
      \ 'quickhelpText': 'open with external association',
      \ })

function! NERDTreeOpenCurrentNodeWithExternalAssociation()
  " Get the path of the item under the cursor if possible:
  let current_file = g:NERDTreeFileNode.GetSelected()
  if current_file == {}
    return
  else
    call Open(current_file.path.str())
  endif

  redraw!
endfunction
