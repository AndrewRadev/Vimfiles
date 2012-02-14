" vim: foldmethod=marker
"
" This NERDTree plugin adds a filesystem manipulation menu almost exactly like
" the default one. The difference is that operations that require entering a
" file path, namely "add", "move" and "copy", use a separate one-line buffer
" to receive the input, instead of the default vim dialog. This allows you to
" use vim keybindings to move around the file path.
"
" Most of the code here is taken directly from Marty Grenfell's original
" fs_menu plugin, which can be found here:
"
" https://github.com/scrooloose/nerdtree/blob/master/nerdtree_plugin/fs_menu.vim
"
" A few minor things have been reformatted, because I liked them better that
" way.
"
" The custom mappings for the special buffer holding the filename are as
" follows:
"
"   - "o" and "O" do nothing in normal mode, to avoid opening up a second line
"     by accident
"   - "Escape" (or "Ctrl+[") in normal mode closes the buffer, cancelling the
"     operation
"   - "Ctrl+c" closes the buffer in both normal and insert mode, cancelling
"     the operation
"   - "Return" in both normal and insert mode executes the operation and
"     closes the buffer
"
" Note that the "Return" key works even when the completion menu is opened --
" you can't use completion in this buffer (a bit of a problem). To that end,
" if you're using the Acp plugin, it's automatically disabled for the buffer.
"
" If you leave the buffer, it's automatically closed.

if exists("g:loaded_nerdree_buffer_fs_menu")
  finish
endif
let g:loaded_nerdtree_fs_menu       = 1 " Don't load default menu
let g:loaded_nerdree_buffer_fs_menu = 1

call NERDTreeAddMenuItem({
      \ 'text':     '(a)dd a childnode',
      \ 'shortcut': 'a',
      \ 'callback': 'NERDTreeAddNodeWithTemporaryBuffer'
      \ })
call NERDTreeAddMenuItem({
      \ 'text':     '(m)ove the current node',
      \ 'shortcut': 'm',
      \ 'callback': 'NERDTreeMoveNodeWithTemporaryBuffer'
      \ })
call NERDTreeAddMenuItem({
      \ 'text':     '(d)elete the curent node',
      \ 'shortcut': 'd',
      \ 'callback': 'NERDTreeDeleteNode'
      \ })
if g:NERDTreePath.CopyingSupported()
  call NERDTreeAddMenuItem({
        \ 'text':     '(c)opy the current node',
        \ 'shortcut': 'c',
        \ 'callback': 'NERDTreeCopyNodeWithTemporaryBuffer'
        \ })
endif

function! NERDTreeMoveNodeWithTemporaryBuffer()
  let current_node = g:NERDTreeFileNode.GetSelected()
  let path         = current_node.path.str()

  call lib#NERDTreeInputBufferSetup(current_node, path, 'basename', 'NERDTreeExecuteMove')
  setlocal statusline=Move
endfunction

function! NERDTreeExecuteMove(current_node, new_path)
  let current_node = a:current_node
  let new_path     = a:new_path

  try
    let bufnum = bufnr(current_node.path.str())

    call current_node.rename(new_path)
    call NERDTreeRender()

    if bufnum != -1
      call s:delBuffer(bufnum)
    endif

    call current_node.putCursorHere(1, 0)
    redraw!

    call s:echo('Node moved to '.new_path)
  catch /^NERDTree/
    call s:echoWarning("Node Not Renamed.")
  endtry
endfunction

function! NERDTreeAddNodeWithTemporaryBuffer()
  let current_node = g:NERDTreeDirNode.GetSelected()
  let path         = current_node.path.str({'format': 'Glob'}) . g:NERDTreePath.Slash()

  call lib#NERDTreeInputBufferSetup(current_node, path, 'append', 'NERDTreeExecuteAdd')
  setlocal statusline=Add
endfunction

function! NERDTreeExecuteAdd(current_node, new_node_name)
  let current_node  = a:current_node
  let new_node_name = a:new_node_name

  if new_node_name ==# ''
    call s:echo("Node Creation Aborted.")
    return
  endif

  try
    let new_path    = g:NERDTreePath.Create(new_node_name)
    let parent_node = b:NERDTreeRoot.findNode(new_path.getParent())

    let new_tree_node = g:NERDTreeFileNode.New(new_path)
    if parent_node.isOpen || !empty(parent_node.children)
      call parent_node.addChild(new_tree_node, 1)
      call NERDTreeRender()
      call new_tree_node.putCursorHere(1, 0)
    endif

    call s:echo('Node created as ' . new_node_name)
  catch /^NERDTree/
    call s:echoWarning("Node Not Created.")
  endtry
endfunction

function! NERDTreeCopyNodeWithTemporaryBuffer()
  let current_node = g:NERDTreeFileNode.GetSelected()
  let path         = current_node.path.str()

  call lib#NERDTreeInputBufferSetup(current_node, path, 'basename', 'NERDTreeExecuteCopy')
  setlocal statusline=Copy
endfunction

function! NERDTreeExecuteCopy(current_node, new_path)
  let current_node = a:current_node
  let new_path     = a:new_path

  if new_path != ""
    "strip trailing slash
    let new_path = substitute(new_path, '\/$', '', '')

    let confirmed = 1
    if current_node.path.copyingWillOverwrite(new_path)
      call s:echo("Warning: copying may overwrite files! Continue? (yN)")
      let choice = nr2char(getchar())
      let confirmed = choice ==# 'y'
    endif

    if confirmed
      try
        call s:echo("Copying...")
        let new_node = current_node.copy(new_path)
        if !empty(new_node)
          call NERDTreeRender()
          call new_node.putCursorHere(0, 0)
        endif
        call s:echo("Copied to " . new_path)
      catch /^NERDTree/
        call s:echoWarning("Could not copy node")
      endtry
    endif
  else
    call s:echo("Copy aborted.")
  endif
  redraw
endfunction

function! NERDTreeDeleteNode()
  let currentNode = g:NERDTreeFileNode.GetSelected()
  let confirmed = 0

  if currentNode.path.isDirectory
    let choice =input("Delete the current node\n" .
          \ "==========================================================\n" .
          \ "STOP! To delete this entire directory, type 'yes'\n" .
          \ "" . currentNode.path.str() . ": ")
    let confirmed = choice ==# 'yes'
  else
    echo "Delete the current node\n" .
          \ "==========================================================\n".
          \ "Are you sure you wish to delete the node:\n" .
          \ "" . currentNode.path.str() . " (yN):"
    let choice = nr2char(getchar())
    let confirmed = choice ==# 'y'
  endif

  if confirmed
    try
      call currentNode.delete()
      call NERDTreeRender()

      let bufnum = bufnr(currentNode.path.str())
      if buflisted(bufnum)
        call s:delBuffer(bufnum)
      endif

      redraw
    catch /^NERDTree/
      call s:echoWarning("Could not remove node")
    endtry
  else
    call s:echo("delete aborted")
  endif
endfunction

function! s:echo(msg)
  redraw
  echomsg "NERDTree: " . a:msg
endfunction

function! s:echoWarning(msg)
  echohl warningmsg
  call s:echo(a:msg)
  echohl normal
endfunction

"Delete the buffer with the given bufnum.
"
"Args:
"bufnum: the buffer that may be deleted
function! s:delBuffer(bufnum)
  exec "silent bdelete! " . a:bufnum
endfunction
