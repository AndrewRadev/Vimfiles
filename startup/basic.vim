set autoindent
set autowrite
set backspace=indent,eol,start
set clipboard=unnamed
set cmdheight=1
set complete=.,w,b,i
set completeopt=menuone,longest
set diffopt=filler,vertical
set encoding=utf-8
set expandtab smarttab
set ffs=unix,dos
set formatoptions=croqn
set guioptions=crb
set incsearch nohlsearch
set laststatus=2
set lazyredraw
set linebreak showbreak=+>
set listchars=eol:.,tab:\|-
set noswapfile
set notimeout
set number
set ruler
set shiftwidth=2 shiftround
set shortmess=aTI
set showcmd
set sidescroll=4
set statusline=%<%f\ %h%m%r%=%-14.([%l/%L],%c%V%)\ %P
set t_Co=256
set tabstop=2 softtabstop=2
set ttimeout
set updatetime=1000
set wildmenu

if has("win32")
  set backupdir=c:/tmp
  set guifont=Inconsolata:h15,Andale_Mono:h12,DejaVu_Sans_Mono:h12
else
  set backupdir=~/.backup
"  set guifont=Andale\ Mono\ 13
  set guifont=Inconsolata\ 15
endif
