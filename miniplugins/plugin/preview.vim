" This script makes it easy to generate the preview of a file using some
" external program. This could probably be used for any kind of file that
" requires some preprocessing before usage, like coffeescript or markdown.
"
" The preview's parameters are defined using the function SetupPreview. Its
" first parameter is the extension of the processed filetype, the second one
" is the shell command to execute, with %s being replaced by the current
" file's filename.
"
" Examples:
"
"   call SetupPreview('js', 'coffee -p %s')
"   call SetupPreview('markdown', 'markdown %s')
"
" To open up the preview window use the command :Preview. After that, it will
" be updated upon saving the original buffer.

command! Preview call s:InitPreview()

function! SetupPreview(extension, command)
  let b:preview_file    = tempname().'.'.a:extension
  let b:preview_command = printf(a:command, shellescape(expand('%')))
  let b:preview_command .= ' > ' . b:preview_file . ' 2>&1'

  autocmd BufWritePost <buffer>
        \ if bufwinnr(b:preview_file) >= 0 |
        \   call UpdatePreview()           |
        \ endif
endfunction

function! s:InitPreview()
  if !exists('b:preview_file')
    echoerr 'No preview command has been defined for this buffer.'
    return
  endif

  if bufwinnr(b:preview_file) < 0
    let original_buffer = bufnr('%')
    exe 'split '.b:preview_file
    call lib#SwitchWindow(original_buffer)
  endif

  call UpdatePreview()
endfunction

function! UpdatePreview()
  if !exists('b:preview_file') || bufwinnr(b:preview_file) < 0
    return
  endif

  call system(b:preview_command)

  let original_buffer = bufnr('%')
  call lib#SwitchWindow(b:preview_file)
  silent edit!
  syntax on " workaround for weird lack of syntax
  normal! zR
  call lib#SwitchWindow(original_buffer)
endfunction
