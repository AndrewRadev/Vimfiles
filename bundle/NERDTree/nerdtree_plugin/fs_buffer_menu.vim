if exists("g:loaded_nerdree_buffer_fs_menu")
  finish
endif
let g:loaded_nerdree_buffer_fs_menu = 1

call NERDTreeAddMenuItem({
      \ 'text': '(M)ove the curent node with temporary buffer',
      \ 'shortcut': 'M',
      \ 'callback': 'NERDTreeMoveNodeWithTemporaryBuffer'
      \ })

function! NERDTreeMoveNodeWithTemporaryBuffer()
  let current_node = g:NERDTreeFileNode.GetSelected()
  let path         = current_node.path.str()

  " setup menu buffer
  botright 1new
  call setline(1, path)
  normal! $T/
  setlocal nomodified
  setlocal statusline=Move
  let b:current_node = current_node

  " guard against problems. TODO needs to be more robust?
  nmap <buffer> o <nop>
  nmap <buffer> O <nop>

  " setup callback
  nmap <buffer> <cr> :call <SID>ExecuteMove(b:current_node, getline('.'))<cr>
  imap <buffer> <cr> <esc>:call <SID>ExecuteMove(b:current_node, getline('.'))<cr>

  " setup cancelling
  nmap <buffer> <esc> :q!<cr>
  nmap <buffer> <c-[> :q!<cr>
endfunction

function! s:ExecuteMove(current_node, new_path)
  let current_node = a:current_node
  let new_path     = a:new_path

  " close the temporary buffer TODO check if it's the same one?
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

"FUNCTION: s:echoWarning(msg){{{1
function! s:echoWarning(msg)
    echohl warningmsg
    call s:echo(a:msg)
    echohl normal
endfunction
