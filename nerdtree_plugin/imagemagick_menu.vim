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
    call lib#NERDTreeInputBufferSetup(current_file, path, 'basename', 'NERDTreeExecuteConvert')
    setlocal statusline=Convert
  endif

  redraw!
endfunction

function! NERDTreeExecuteConvert(current_node, command_line)
  let external_command = 'convert '.a:current_node.path.str().' '.a:command_line

  echomsg external_command
  let output = system(external_command)

  if v:shell_error == 0
    redraw
    echomsg 'Image converted as '.a:command_line
    call b:NERDTreeRoot.refresh()
    call NERDTreeRender()
  else
    echohl WarningMsg
    echomsg 'Error in command line: '.output
    echohl None
  endif
endfunction
