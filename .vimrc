set nocompatible

filetype plugin on
filetype indent on
syntax on

colo custom_elflord

" Load settings:
runtime! startup/basic.vim
runtime! startup/autocommands.vim
runtime! startup/utl.vim
runtime! startup/smartword.vim
runtime! startup/search.vim
runtime! startup/visual_search.vim
runtime! startup/plugins.vim
runtime! startup/commands.vim

" Toggle settings:
command! -nargs=+ MapToggle call lib#MapToggle(<f-args>)

" Edit important files quickly:
command! Eclipboard ClipBrd
command! Epasswords edit ~/.passwords

" Rebuild tags database:
command! RebuildTags !ctags -R .

" Generic console, override in different filetypes:
if has('win32')
  command! Console !start cmd
else
  command! Console !urxvt &
endif

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap

" Some annoying mappings removed:
nnoremap s <Nop>
"nnoremap <C-p> <Nop>

" Always move through visual lines:
nnoremap j gj
nnoremap k gk

" Moving through tabs:
nmap <C-l> gt
nmap <C-h> gT

" Moving through splits:
nmap gh <C-w>h
nmap gj <C-w>j
nmap gk <C-w>k
nmap gl <C-w>l

" Faster scrolling:
nmap J 4j
nmap K 4k

" Use <bs> to go back through jumps:
nnoremap <bs> <C-o>

" Completion remappings:
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
inoremap <C-o> <C-x><C-o>
inoremap <C-u> <C-x><C-u>
inoremap <C-f> <C-x><C-f>
inoremap <C-]> <C-x><C-]>
inoremap <C-l> <C-x><C-l>
set completefunc=syntaxcomplete#Complete

" Moving lines:
noremap  <C-j> mz:m+<cr>`z
noremap  <C-k> mz:m-2<cr>`z
vnoremap <C-j> :m'>+<cr>`<my`>mzgv`yo`z
vnoremap <C-k> :m'<-2<cr>`>my`<mzgv`yo`z

" For digraphs:
inoremap <C-n> <C-k>

" <Tab> with folds:
nmap <Tab> zA

" Open all occurences of word under cursor in quickfix:
noremap [gI :execute 'vimgrep '.expand('<cword>').' '.expand('%')\|:copen\|:cc<cr>

" Alignment mappings:
vmap <Leader>a=> :Align =><cr>

source ~/.local_vimrc
