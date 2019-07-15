command! SyntaxTrace call s:SyntaxTrace()
function! s:SyntaxTrace()
  let b:syntax_popup = -1

  augroup syntax_trace
    autocmd!

    autocmd CursorMoved * call s:UpdateSyntaxPopup()
  augroup END
endfunction

function! s:UpdateSyntaxPopup()
  if expand('<cword>') == ''
    call popup_close(b:syntax_popup)
  else
    let syntax_info = synIDattr(synID(line('.'), col('.'), 1), "name")
    call popup_close(b:syntax_popup)

    if syntax_info != ''
      let b:syntax_popup = popup_atcursor(syntax_info, {
            \ "border": [],
            \ })
    endif
  endif
endfunction
