if exists("g:loaded_nerdree_interactive_edit")
  finish
endif
let g:loaded_nerdree_interactive_edit = 1

call NERDTreeAddMenuItem({
      \ 'text': '(e)dit directory contents',
      \ 'shortcut': 'e',
      \ 'callback': 'NERDTreeInteractiveEdit'
      \ })

function! NERDTreeInteractiveEdit()
  " get the current dir from NERDTree
  let dir = g:NERDTreeDirNode.GetSelected().path.str()
  let files = glob(dir.'/*', 0, 1)

  botright new
  exe "edit ".tempname()

  call s:SetupBufferProperties()
  call s:SetupBufferContents(dir, files)
  call s:SetupBufferCallbacks()
endfunction

function! NERDTreeInteractiveEditExecute()
  let dir      = getline(1)
  let commands = []

  for line in getbufline('%', 4, line('$'))
    let parts = split(line, '\s* -> \s*')

    if len(parts) < 2
      let original = substitute(parts[0], '\s*->\s*$', '', '')
      let modified = ''
    elseif len(parts) == 2
      let [original, modified] = parts
    else
      echoerr "Too many \"->\" matched on line"
      return
    endif

    if modified =~ '^\s*$'
      call add(commands, ['delete', original])
    elseif modified ==# original
      " do nothing
    else
      call add(commands, ['rename', original, modified])
    endif
  endfor

  echo
  for command in commands
    let [function; args] = command
    echomsg function.'('.join(args, ', ').')'

    try
      call call(function, args)
    catch /.*/
      echohl Error
      echomsg '  -> '.v:exception
      echohl None
    endtry
  endfor
endfunction

function! s:SetupBufferProperties()
endfunction

function! s:SetupBufferContents(dir, files)
  call append(0, a:dir)
  call append(1, repeat('=', len(a:dir)))

  let max_length = max(map(copy(a:files), 'len(v:val)'))

  for filename in a:files
    let whitespace = repeat(' ', max_length - len(filename))
    call append(line('$'), filename.whitespace.' -> '.filename)
  endfor

  set nomodified
endfunction

function! s:SetupBufferCallbacks()
  autocmd BufWritePost <buffer> call NERDTreeInteractiveEditExecute() | quit!
endfunction
