" Requires: Utl
if !exists("loaded_utl")
  finish
endif

call NERDTreeAddKeyMap({
      \ 'key': 'gu',
      \ 'callback': 'NERDTreeOpenCurrentNodeWithUtl',
      \ 'quickhelpText': 'open with Utl plugin' })

function! NERDTreeOpenCurrentNodeWithUtl()
  " Get the path of the item under the cursor if possible:
  let currentFile = g:NERDTreeFileNode.GetSelected()
  if currentFile == {}
    return
  endif

  let link = currentFile.path.str()

  if has('mac')
    call system('open '.shellescape(link).' &')
    return
  endif

  " Convert it to the format Utl expects:
  let link = substitute(link, '\', '/', 'g')
  let link = substitute(link, ' ', '%20', 'g')
  let link = 'file://' . link

  silent call Utl('openLink', link)
  redraw!
endfunction
