if !has('textprop')
  finish
endif

" Define what color the private area will be
hi rubyPrivateMethod cterm=underline gui=underline

function! s:MarkPrivateArea()
  if empty(prop_type_get('private_method', {'bufnr': bufnr('%')}))
    call prop_type_add('private_method', {
          \ 'bufnr':     bufnr('%'),
          \ 'highlight': 'rubyPrivateMethod',
          \ 'combine':   v:true
          \ })
  endif

  " Clear out any previous matches
  call prop_remove({'type': 'private_method', 'all': v:true})

  " Store the current view, in order to restore it later
  let saved_view = winsaveview()

  " start at the last char in the file and wrap for the
  " first search to find match at start of file
  normal! G$
  let flags = "w"
  while search('\<private\>', flags) > 0
    let flags = "W"

    if s:CurrentSyntaxName() !~# "rubyAccess"
      " it's not a real access modifier, keep going
      continue
    endif

    let start_line = line('.')
    let end_line = line('.')

    " look for the matching "end"
    let saved_position = getpos('.')
    while search('\<end\>', 'W') > 0
      if s:CurrentSyntaxName() !~# "rubyClass"
        " it's not an end that closes a class, keep going
        continue
      endif

      let end_line = line('.') - 1
      break
    endwhile

    exe start_line

    while search('\<def\>', 'W', end_line) > 0
      if s:CurrentSyntaxName() !~# "rubyDefine"
        " it's not a "def" that defines a function
        continue
      endif

      call prop_add(line('.'), col('.'), {
            \ 'length': '3',
            \ 'type': 'private_method'
            \ })
    endwhile

    " restore where we were before we started looking for the "end"
    call setpos('.', saved_position)
  endwhile

  " We're done highlighting, restore the view to what it was
  call winrestview(saved_view)
endfunction

function! s:CurrentSyntaxName()
  return synIDattr(synID(line("."), col("."), 0), "name")
endfunction

" Initial marking
autocmd BufEnter <buffer> call <SID>MarkPrivateArea()

" Mark upon writing
autocmd BufWrite <buffer> call <SID>MarkPrivateArea()

" Mark when exiting insert mode (doesn't cover normal-mode text changing)
" autocmd InsertLeave <buffer> call <SID>MarkPrivateArea()
"
" Mark when text has changed in normal mode. (doesn't work sometimes, syntax
" doesn't get updated in time)
" autocmd TextChanged <buffer> call <SID>MarkPrivateArea()

" Mark when not moving the cursor for 'timeoutlen' time
" autocmd CursorHold <buffer> call <SID>MarkPrivateArea()
