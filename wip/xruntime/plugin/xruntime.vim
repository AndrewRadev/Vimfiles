if exists('g:loaded_xruntime') || &cp
  finish
endif

let g:loaded_xruntime = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

command! -nargs=+ Xruntime call xruntime#Runtime(<f-args>)
command! -nargs=+ Xsource  call xruntime#Source(<f-args>)

let &cpo = s:keepcpo
unlet s:keepcpo
