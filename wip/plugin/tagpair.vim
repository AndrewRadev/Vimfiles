nnoremap cw  :call <SID>ChangeTag('w')<cr>
nnoremap ce  :call <SID>ChangeTag('e')<cr>
nnoremap ciw :call <SID>ChangeTag('iw')<cr>
nnoremap caw :call <SID>ChangeTag('aw')<cr>
nnoremap ci< :call <SID>ChangeTag('i<')<cr>
nnoremap ci> :call <SID>ChangeTag('i>')<cr>
nnoremap ct> :call <SID>ChangeTag('t>')<cr>

" TODO (2019-04-14) Store and restore typeahead? (Fast typing)
" (inputsave/inputrestore)

" TODO (2019-04-14) Visual + c?
" TODO (2019-04-14) repeat.vim support

" TODO (2019-04-12) autocmd -buffer? Multiple sourcing?
augroup tag_edit
  autocmd!

  autocmd InsertLeave * call s:ReplaceMatchingTag()
augroup END

" TODO (2019-04-12) Inline sj#SearchUnderCursor()
" TODO (2019-04-12) Inline sj#PushCursor()
" TODO (2019-04-12) Inline sj#PopCursor()
" TODO (2019-04-12) Inline sj#GetByPosition()
"
" TODO (2019-04-12) Document: Requires matchit

function! s:ChangeTag(motion)
  call sj#PushCursor()

  if sj#SearchUnderCursor('<\zs\k\+')
    " We are on an opening tag
    let tag = expand('<cword>')

    let opening_position = getpos('.')
    normal %
    let closing_position = getpos('.')

    if opening_position != closing_position && sj#SearchUnderCursor('</\V'.tag.'>', 'n')
      " match seems to position cursor on the `/` of `</tag`
      let closing_position[2] += 1

      let b:old_tag              = tag
      let b:motion               = a:motion
      let b:changed_tag          = 'opening'
      let b:opening_tag_position = opening_position
      let b:closing_tag_position = closing_position
    endif
  elseif sj#SearchUnderCursor('</\zs\k\+>')
    " We are on a closing tag
    let tag = expand('<cword>')

    let closing_position = getpos('.')
    normal %
    let opening_position = getpos('.')

    if opening_position != closing_position && sj#SearchUnderCursor('<\V'.tag.'\m\>', 'n')
      let b:old_tag              = tag
      let b:motion               = a:motion
      let b:changed_tag          = 'closing'
      let b:opening_tag_position = opening_position
      let b:closing_tag_position = closing_position
    endif
  endif

  call sj#PopCursor()

  call feedkeys('c'.a:motion, 'n')
endfunction

function! s:ReplaceMatchingTag()
  if !exists('b:old_tag')
    return
  endif

  call sj#PushCursor()

  let changed_tag          = b:changed_tag          | unlet b:changed_tag
  let motion               = b:motion               | unlet b:motion
  let old_tag              = b:old_tag              | unlet b:old_tag
  let closing_tag_position = b:closing_tag_position | unlet b:closing_tag_position
  let opening_tag_position = b:opening_tag_position | unlet b:opening_tag_position

  if changed_tag == 'opening'
    let new_content = sj#GetByPosition(opening_tag_position, getpos('.'))
    let new_tag = matchstr(new_content, '^\s*\zs\k\+')
  else
    let new_content = expand('<cword>')
    let new_tag = new_content
  endif

  " Debug [old_tag, new_tag, opening_tag_position, closing_tag_position]

  if new_tag !~ '^\k\+$'
    " we've had a change that resulted in something weird, like an empty
    " <></>, bail out
    call sj#PopCursor()
    return
  endif

  undo

  " First the closing, in case the length changes:
  call setpos('.', closing_tag_position)
  call s:ReplaceMotion('v'.motion, new_tag)

  " Then the opening tag:
  call setpos('.', opening_tag_position)
  call s:ReplaceMotion('v'.motion, new_content)

  call sj#PopCursor()
endfunction

function! s:ReplaceMotion(motion, text)
  " reset clipboard to avoid problems with 'unnamed' and 'autoselect'
  let saved_clipboard = &clipboard
  set clipboard=

  let saved_register_text = getreg('"', 1)
  let saved_register_type = getregtype('"')

  call setreg('"', a:text, 'v')
  exec 'silent normal! '.a:motion.'p'

  call setreg('"', saved_register_text, saved_register_type)
  let &clipboard = saved_clipboard
endfunction
