let s:syntax_popup = 0

command! SyntaxPopup call s:TogglePopup()

function! s:ShowPopup()
  let syn_id = synID(line('.'), col('.'), 1)
  if syn_id == 0
    return
  endif

  let syn_name  = synIDattr(syn_id, "name")
  let highlight = synIDattr(synIDtrans(syn_id), "name")
  let text = syn_name .. " (" .. highlight .. ")"

  let s:syntax_popup = popup_atcursor(text, {'border': []})
endfunction

function! s:HidePopup()
  call popup_clear(s:syntax_popup)
  let s:syntax_popup = 0
endfunction

function! s:TogglePopup()
  if s:syntax_popup > 0
    call s:DisablePopup()
  else
    call s:EnablePopup()
  endif
endfunction

function! s:EnablePopup()
  call s:ShowPopup()

  augroup syntax_popup
    autocmd!
    autocmd CursorMoved * call s:ShowPopup()
  augroup END
endfunction

function! s:DisablePopup()
  augroup syntax_popup
    autocmd!
  augroup END

  call s:HidePopup()
endfunction
