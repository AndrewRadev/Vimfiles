set autoindent
set autoread
set autowrite
set backspace=indent,eol,start
set clipboard=unnamed,html
set cmdheight=1
set complete=.,w,b,k
set completeopt=menuone,longest
set cscopequickfix=s-,c-,d-,i-,t-,e-
set cscopetagorder=1 " Look in tags file first
set diffopt=filler,vertical
set encoding=utf-8
set expandtab smarttab
set ffs=unix
set fillchars=stl:-,stlnc:-,vert:\|,fold:-,diff:-
set formatoptions=croqn
set guioptions=crb
set incsearch nohlsearch
set laststatus=2
set linebreak showbreak=+>
set listchars=eol:.,tab:\|-
set nobackup
set nocscopetag
set noswapfile
set notimeout
set nottybuiltin
set nowritebackup
set number
set ruler
set shiftwidth=2 shiftround
set shortmess=aTI
set showcmd
set sidescroll=4
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=[%{&ft}]%-14.([%l/%L],%c%V%)\ %P
set t_Co=256
set tabstop=2 softtabstop=2
set ttimeout
set ttimeoutlen=200
set updatetime=1000
set wildmenu
set wildmode=list:longest,full

" Use vim-based Bulgarian keymaps
set keymap=custom_bg_phonetic
set iminsert=0
set imsearch=-1

let mapleader="_"
let maplocalleader="_"

let apache_version = "2.2"

if has("win32")
  set guifont=Terminus:h15,DejaVu_Sans_Mono:h12
else
  set guifont=Terminus\ 14,Andale\ Mono\ 13
endif
