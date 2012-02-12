" vim: foldmethod=marker

" TODO (2012-02-07) Extract some functions to make extending the NERDTree easier

if exists('g:loaded_nerdree_imagemagick_menu')
  finish
endif
let g:loaded_nerdree_imagemagick_menu = 1

call NERDTreeAddMenuItem({
      \ 'text': '(i)magemagick processing',
      \ 'shortcut': 'i',
      \ 'callback': 'NERDTreeImageMagickProcessing'
      \ })

"FUNCTION: NERDTreeImageMagickProcessing(){{{1
function! NERDTreeImageMagickProcessing()
  let current_file = g:NERDTreeFileNode.GetSelected()

  if current_file == {}
    return
  else
    let path = fnamemodify(current_file.path.str(), ':.')
    call lib#NERDTreeInputBuffer(current_file, path, 'basename')
    setlocal statusline=Convert

    " setup callback
    nmap <buffer> <cr> :call <SID>ExecuteConvert(b:node, getline('.'))<cr>
    imap <buffer> <cr> <esc>:call <SID>ExecuteConvert(b:node, getline('.'))<cr>
  endif

  redraw!
endfunction

"FUNCTION: s:ExecuteConvert(current_node, command_line){{{1
function! s:ExecuteConvert(current_node, command_line)
  let current_node = a:current_node
  let command_line = a:command_line

  " close the temporary buffer
  q!

  echomsg 'convert '.current_node.path.str().' '.shellescape(command_line)
  let output = system('convert '.current_node.path.str().' '.command_line)

  if v:shell_error == 0
    call s:echo('Image converted as '.command_line)
    call b:NERDTreeRoot.refresh()
    call NERDTreeRender()
  else
    call s:echoWarning('Error in command line: '.output)
  endif
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
