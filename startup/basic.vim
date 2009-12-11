set autoindent
set autoread
set autowrite
set backspace=indent,eol,start
set cmdheight=1
set complete=.,w,b,k
set completeopt=menuone,longest
set diffopt=filler,vertical
set encoding=utf-8
set expandtab smarttab
set ffs=unix,dos
set formatoptions=croqn
set guioptions=crb
set incsearch nohlsearch
set laststatus=2
set linebreak showbreak=+>
"set list
set listchars=eol:.,tab:\|-
set noswapfile
set notimeout
set number
set ruler
set shiftwidth=2 shiftround
set shortmess=aTI
set showcmd
set sidescroll=4
set statusline=%<%f\ %h%m%r%=[%{&ft}]%-14.([%l/%L],%c%V%)\ %P
set t_Co=256
set tabstop=2 softtabstop=2
set ttimeout
set updatetime=1000
set wildmenu

let mapleader="_"
let maplocalleader="_"

if has("win32")
  set clipboard=unnamed
  set backupdir=c:/tmp
  set guifont=Terminus:h15,DejaVu_Sans_Mono:h12
else
  set guifont=Terminus\ 14
  set backupdir=~/.backup
endif
