" Taken from: https://www.reddit.com/r/vim/comments/lax28o/useful_autocomand/glqrcim

augroup Sarcasm
  autocmd!
augroup END

function s:Sarcasm(enabled)
  autocmd! Sarcasm InsertCharPre
  if a:enabled
    autocmd Sarcasm InsertCharPre * if rand() % 2 | let v:char = toupper(v:char) | endif
    return "sARcaSm: oN"
  else
    return "Sarcasm: off"
  endif
endfunction

command! -nargs=0 -bang Sarcasm echo s:Sarcasm(<bang>1)
