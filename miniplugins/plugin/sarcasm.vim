" Taken from: https://www.reddit.com/r/vim/comments/lax28o/useful_autocomand/glqrcim

function s:Sarcasm(enabled)
  augroup Sarcasm
    autocmd!

    if a:enabled
      autocmd InsertCharPre * if rand() % 2 | let v:char = toupper(v:char) | endif
      return "sARcaSm: oN"
    else
      return "Sarcasm: off"
    endif
  augroup END
endfunction

command! -nargs=0 -bang Sarcasm echo s:Sarcasm(<bang>1)
