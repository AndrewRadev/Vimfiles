set nocompatible

call pathogen#infect()

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
runtime startup/external_open.vim
runtime startup/acp.vim
runtime startup/cyrillic.vim

runtime! ftplugin/man.vim

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

source ~/.local_vimrc
