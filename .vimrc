set nocompatible

call pathogen#infect()
call pathogen#helptags()

filetype plugin on
filetype indent on
syntax on

colo andrew

runtime startup/settings.vim
runtime startup/plugins.vim
runtime startup/smartword.vim
runtime startup/commands.vim
runtime startup/autocommands.vim
runtime startup/mappings.vim
runtime startup/acp.vim
runtime startup/cyrillic.vim

runtime! ftplugin/man.vim
autocmd FileType man setlocal foldmethod=indent

" Add "personal" directory to runtimepath
set runtimepath+=~/.vim/personal
for dir in split(glob('~/.vim/personal/*'), "\n")
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
