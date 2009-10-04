set autoindent
set backspace=indent,eol,start
set clipboard=unnamed
set cmdheight=1
set completeopt=longest,menuone
set diffopt=filler,vertical
set encoding=utf-8
set expandtab
set ffs=unix,dos
set guioptions=crb
set ignorecase smartcase
set incsearch
set laststatus=2
set lazyredraw
set linebreak
set nocompatible
set nohlsearch
set noswapfile
set number
set path=./**
set ruler
set shiftround
set shiftwidth=2
set shortmess=aTI
set showbreak=+>
set showcmd
set sidescroll=4
set smarttab
set softtabstop=2
set t_Co=256
set tabstop=2
set wildmenu

if has("win32")
  set backupdir=c:/tmp
  set guifont=DejaVu_Sans_Mono:h14
else
  set backupdir=~/.backup
  set guifont=Andale\ Mono\ 14
endif

syntax enable
filetype plugin indent on

colorscheme custom_elflord
