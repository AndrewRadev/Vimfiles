" :StartupTime requires it:
set nocompatible

call pathogen#infect()
call pathogen#helptags()

filetype plugin on
filetype indent on
syntax on

colo andrew

runtime startup/settings.vim
runtime startup/plugins.vim
runtime startup/commands.vim
runtime startup/autocommands.vim
runtime startup/mappings.vim
runtime startup/acp.vim
runtime startup/cyrillic.vim
runtime startup/windows.vim

runtime! ftplugin/man.vim
autocmd FileType man setlocal foldmethod=indent

" Add "miniplugins" directory to runtimepath
set runtimepath+=~/.vim/miniplugins
for dir in split(glob('~/.vim/miniplugins/*'), "\n")
  exe "set runtimepath+=".dir
endfor

" Add "wip" directory to runtimepath
set runtimepath+=~/.vim/wip
for dir in split(glob('~/.vim/wip/*'), "\n")
  exe "set runtimepath+=".dir
endfor

if filereadable(fnamemodify('~/.vimrc.local', ':p'))
  source ~/.vimrc.local
endif

" Presentation mode
" set background=light
" colo PaperColor
" let g:NERDTreeWinSize = 20
" set nowrap
