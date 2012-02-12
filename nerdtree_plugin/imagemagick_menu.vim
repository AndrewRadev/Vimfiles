" vim: foldmethod=marker

if exists('g:loaded_nerdree_imagemagick_menu')
  finish
endif
let g:loaded_nerdree_imagemagick_menu = 1

call NERDTreeAddMenuItem({
      \ 'text':     '(i)magemagick processing',
      \ 'shortcut': 'i',
      \ 'callback': 'NERDTreeImageMagickProcessing'
      \ })

function! NERDTreeImageMagickProcessing()
  let current_file = g:NERDTreeFileNode.GetSelected()

  if current_file == {}
    return
  else
    let path = fnamemodify(current_file.path.str(), ':.')
    call lib#NERDTreeInputBufferSetup(current_file, path, 'basename', function('NERDTreeExecuteConvert'))
    setlocal statusline=Convert
  endif

  redraw!
endfunction

function! NERDTreeExecuteConvert(current_node, command_line)
  let current_node = a:current_node
  let command_line = a:command_line

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

function! s:echo(msg)
  redraw
  echomsg "NERDTree: " . a:msg
endfunction

function! s:echoWarning(msg)
  echohl warningmsg
  call s:echo(a:msg)
  echohl normal
endfunction
