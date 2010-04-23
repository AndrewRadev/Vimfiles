set nocompatible

filetype plugin on
filetype indent on
syntax on

colo custom_elflord

runtime! startup/*.vim
runtime! ftplugin/man.vim

" Get rid of annoying register rewriting when pasting on visually selected
" text.
function! RestoreRegister()
  let @" = s:restore_reg
  let @* = s:restore_reg_star
  let @+ = s:restore_reg_plus
  return ''
endfunction
function! s:Repl()
  let s:restore_reg      = @"
  let s:restore_reg_star = @*
  let s:restore_reg_plus = @+
  return "p@=RestoreRegister()\<cr>"
endfunction
xnoremap <silent> <expr> p <SID>Repl()

" Indent some additional html tags:
let g:html_indent_tags = 'p\|li'

" Remove match paren again and find a goddamn way to fix it.
let loaded_matchparen = 1

source ~/.local_vimrc
