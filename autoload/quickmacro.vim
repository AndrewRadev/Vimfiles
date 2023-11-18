let s:recording = v:false

function! quickmacro#Record() abort
  if s:recording
    normal! qm
    let s:recording = v:false

    silent! call repeat#set(":call quickmacro#Run()\<cr>")
  else
    let s:recording = v:true

    normal! qm
  endif
endfunction

function! quickmacro#Run() abort
  normal! @m
  silent! call repeat#set(":call quickmacro#Run()\<cr>")
endfunction
