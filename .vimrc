" General settings:
set nocompatible
set backspace=indent,eol,start
set ruler
set laststatus=2
set showcmd
set incsearch
set nohlsearch
set ignorecase smartcase
set autoindent
set number
set wildmenu
set shortmess=aTI
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set expandtab
set smarttab
set completeopt=longest,menuone
set backupdir=~/.backup/
set noswapfile
set encoding=utf-8
set ffs=unix,dos
set sidescroll=4
set path=./**
set linebreak
set showbreak=+>
set lazyredraw
set t_Co=256
set clipboard=unnamed
set diffopt=filler,vertical

" GUI options:
set guifont=Andale\ Mono\ 14
set guioptions=crb

syntax enable
filetype plugin indent on

colo custom_elflord

" Define the toggling function
function! MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  " exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command! -nargs=+ MapToggle call MapToggle(<f-args>)

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

autocmd FileType text setlocal textwidth=98
autocmd BufEnter *.php set filetype=php.html.javascript
autocmd BufEnter *.html set filetype=html.javascript
autocmd BufEnter *.js set filetype=javascript.jquery
autocmd BufEnter *.hs compiler ghc

" Maximise on open on Win32:
if has('win32')
  autocmd GUIEnter * simalt ~x
endif

" Faster movement through tabs:
nmap <C-l> gt
nmap <C-h> gT

" Toggling the NERD tree
nmap gn :NERDTreeToggle<cr>

" Instead of <C-o>, use <bs> to go back files:
nnoremap <bs> <C-o>

" Managing urls (and more):
command! -bar -nargs=1 OpenURL :Utl openLink <args>
nmap gu :Utl<cr>

" Moving through splits:
nmap gh <C-w>h
nmap gj <C-w>j
nmap gk <C-w>k
nmap gl <C-w>l

" Faster scrolling:
nmap J 4j
nmap K 4k

" Completion remappings:
inoremap <C-j> <C-n>
" inoremap <C-k> <C-p>

" Indent/Unindent:
nmap <Tab> >>
nmap <S-Tab> <<

" FindFile mappings:
nmap <C-f> :NERDTreeClose<Space>\|<Space>FF<cr>
imap <C-f> <Esc>:NERDTreeClose<Space>\|<Space>FF<cr>

" Align by columns:
command! -range AlignSpace <line1>,<line2>call lib#AlignSpace()

" Move through visual lines:
nnoremap j gj
nnoremap k gk

" Dbext settings:
let g:dbext_default_buffer_lines = 30

" Snippet settings:
let g:snippets_dir = "~/.vim/custom_snippets/"
let g:snips_author = "Andrew Radev"

" Proj settings:
let g:ProjFile = '$HOME/.vimproj'
let g:ProjSplitMethod = 'edit'

" Some specific files for quick acess:
command! Eclipboard edit `=@*`

command! RefreshTags !ctags -R --sort=foldcase .

" For testing purposes:
let g:autotagVerbosityLevel = 2

" EasyGrep options:
let g:EasyGrepMode              = 2 " Track extension
let g:EasyGrepCommand           = 0 " vimgprep
let g:EasyGrepRecursive         = 1 " -> True
let g:EasyGrepReplaceWindowMode = 0 " At replace, open all in tabs
let g:EasyGrepExtraWarnings     = 1 " -> True

" AutoTags options:
let g:autotagCtagsCmd = "ctags --sort=foldcase"

" FindFile options:
let g:FindFileIgnore = [
      \ '*.o', 
      \ '*.pyc',
      \ '*/tmp/*',
      \ '*.hi',
      \ '*/.svn/*',
      \ '.git/*'
      \ ]

" Utl media handlers:
if has('win32')
  let g:utl_cfg_hdl_mt_generic = 'silent !cmd /q /c start "dummy title" "%P"'
  let g:utl_cfg_hdl_mt_text_directory = ':!start explorer "%P"'
else
  " Generic handler doesn't work without a desktop...
  " Open directories:
  let g:utl_cfg_hdl_mt_text_directory = ':!thunar %p &> /dev/null &'
  " Applications:
  let g:utl_cfg_hdl_mt_application_pdf     = ':!evince  %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_zip     = ':!squeeze %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_x_gzip  = ':!squeeze %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_x_bzip2 = ':!squeeze %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_excel   = ':!soffice %p &> /dev/null &'
  " Images:
  let g:utl_cfg_hdl_mt_image_generic = ':!gliv %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_image_png     = ':!gliv %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_image_jpeg    = ':!gliv %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_image_gif     = ':!gliv %p &> /dev/null &'
  " Video:
  let g:utl_cfg_hdl_mt_video_x_msvideo = ':!smplayer %p &> /dev/null &'
endif

" Settings for Haskell mode:
let g:haddock_browser = "firefox"
let g:haddock_browser_callformat = '%s file://%s &> /dev/null &'
let g:naddock_docdir = '/usr/share/doc/ghc/libraries/html/'
