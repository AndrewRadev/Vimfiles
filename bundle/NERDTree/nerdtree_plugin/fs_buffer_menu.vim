" vim: foldmethod=marker
if exists("g:loaded_nerdree_buffer_fs_menu")
  finish
endif
let g:loaded_nerdree_buffer_fs_menu = 1

call NERDTreeAddMenuItem({
      \ 'text':     '(a)dd a childnode',
      \ 'shortcut': 'a',
      \ 'callback': 'NERDTreeAddNode'
      \ })
call NERDTreeAddMenuItem({
      \ 'text':     '(m)ove the curent node',
      \ 'shortcut': 'm',
      \ 'callback': 'NERDTreeMoveNodeWithTemporaryBuffer'
      \ })

"FUNCTION: NERDTreeMoveNodeWithTemporaryBuffer(){{{1
function! NERDTreeMoveNodeWithTemporaryBuffer()
  let current_node = g:NERDTreeFileNode.GetSelected()
  let path         = current_node.path.str()

  call <SID>SetupMenuBuffer(current_node, path)

  setlocal statusline=Move

  " setup callback
  nmap <buffer> <cr> :call <SID>ExecuteMove(b:current_node, getline('.'))<cr>
  imap <buffer> <cr> <esc>:call <SID>ExecuteMove(b:current_node, getline('.'))<cr>
endfunction

"FUNCTION: s:ExecuteMove(current_node, new_path){{{1
function! s:ExecuteMove(current_node, new_path)
  let current_node = a:current_node
  let new_path     = a:new_path

  " close the temporary buffer
  q!

  try
    let bufnum = bufnr(current_node.path.str())

    call current_node.rename(new_path)
    call NERDTreeRender()

    " if the node is open in a buffer, ask the user if they want to close that
    " buffer
    if bufnum != -1
      let prompt = "\nNode renamed.\n\n"
      let prompt .= "The old file is open in buffer ". bufnum . (bufwinnr(bufnum) ==# -1 ? " (hidden)" : "") . '.'
      let prompt .= "Delete this buffer? (yN)"

      call s:promptToDelBuffer(bufnum, prompt)
    endif

    call current_node.putCursorHere(1, 0)

    redraw!
    echo
  catch /^NERDTree/
    call s:echoWarning("Node Not Renamed.")
  endtry
endfunction

"FUNCTION: NERDTreeAddNodeWithTemporaryBuffer(){{{1
function! NERDTreeAddNodeWithTemporaryBuffer()
  let curDirNode = g:NERDTreeDirNode.GetSelected()

  let newNodeName = input("Add a childnode\n".
        \ "==========================================================\n".
        \ "Enter the dir/file name to be created. Dirs end with a '/'\n" .
        \ "", curDirNode.path.str({'format': 'Glob'}) . g:NERDTreePath.Slash())

  if newNodeName ==# ''
    call s:echo("Node Creation Aborted.")
    return
  endif

  try
    let newPath = g:NERDTreePath.Create(newNodeName)
    let parentNode = b:NERDTreeRoot.findNode(newPath.getParent())

    let newTreeNode = g:NERDTreeFileNode.New(newPath)
    if parentNode.isOpen || !empty(parentNode.children)
      call parentNode.addChild(newTreeNode, 1)
      call NERDTreeRender()
      call newTreeNode.putCursorHere(1, 0)
    endif
  catch /^NERDTree/
    call s:echoWarning("Node Not Created.")
  endtry
endfunction

"FUNCTION: s:SetupMenuBuffer(current_node, path){{{1
function! s:SetupMenuBuffer(current_node, path)
  let current_node = a:current_node
  let path         = a:path

  " one-line buffer, below everything else
  botright 1new

  " check for automatic completion and temporarily disable it
  if exists(':AcpLock')
    AcpLock
    autocmd BufLeave <buffer> AcpUnlock
  endif

  autocmd BufLeave <buffer> q!

  call setline(1, path)
  setlocal nomodified
  let b:current_node = current_node

  " guard against problems
  nmap <buffer> o <nop>
  nmap <buffer> O <nop>

  " cancel action
  nmap <buffer> <esc> :q!<cr>
  nmap <buffer> <c-[> :q!<cr>
  nmap <buffer> <c-c> :q!<cr>
  imap <buffer> <c-c> :q!<cr>

  " go to the end of the filename, ready to type
  call feedkeys('A')
endfunction

"FUNCTION: s:echo(msg){{{1
function! s:echo(msg)
    redraw
    echomsg "NERDTree: " . a:msg
endfunction

"FUNCTION: s:echoWarning(msg){{{1
function! s:echoWarning(msg)
    echohl warningmsg
    call s:echo(a:msg)
    echohl normal
endfunction

"FUNCTION: s:promptToDelBuffer(bufnum, msg){{{1
"prints out the given msg and, if the user responds by pushing 'y' then the
"buffer with the given bufnum is deleted
"
"Args:
"bufnum: the buffer that may be deleted
"msg: a message that will be echoed to the user asking them if they wish to
"     del the buffer
function! s:promptToDelBuffer(bufnum, msg)
    echo a:msg
    if nr2char(getchar()) ==# 'y'
        exec "silent bdelete! " . a:bufnum
    endif
endfunction
