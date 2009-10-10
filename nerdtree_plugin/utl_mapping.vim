" Requires: Utl

call NERDTreeAddKeyMap({
      \ 'key': 'gu',
      \ 'callback': 'OpenCurrentNodeWithUtl',
      \ 'quickhelpText': 'open current node with the Utl plugin' })

function! OpenCurrentNodeWithUtl()
  " Get the path of the item under the cursor if possible:
  let currentDir = g:NERDTreeFileNode.GetSelected()
  if currentDir == {}
    return
  endif

  let link = currentDir.path.str()

  " Convert it to the format Utl expects:
  let link = substitute(link, '\', '/', 'g')
  let link = substitute(link, ' ', '%20', 'g')
  let link = 'file://' . link

  silent call Utl('openLink', link)
  redraw!
endfunction
