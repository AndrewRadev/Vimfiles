set nocompatible

filetype plugin on
filetype indent on
syntax on

colo custom_elflord

" Load settings:
runtime! startup/basic.vim
runtime! startup/autocommands.vim
runtime! startup/utl.vim
runtime! startup/completion.vim
runtime! startup/smartword.vim
runtime! startup/search.vim

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

" NERD tree:
nmap gn :NERDTreeToggle<cr>
nmap gN :NERDTree<cr>

command! FindInTree call FindInNERDTree()

let g:NERDTreeHijackNetrw = 0

" Open up FuzzyFinders:
nmap Qf :FuzzyFinderTextMate<cr>
nmap Qm :FuzzyFinderMruFile<cr>

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

" For digraphs:
inoremap <C-n> <C-k>

" <Tab> with folds:
nmap <Tab> zA

" Dbext settings:
let g:dbext_default_buffer_lines = 20

" Snippet settings:
let g:snippets_dir = "~/.vim/custom_snippets/"
let g:snips_author = "Andrew Radev"

" FuzzyFinderTextMate settings:
let g:fuzzy_ceiling = 20000
let g:fuzzy_ignore = "*/.svn/*;.git/*;*/tmp/*"

" Proj settings:
let g:ProjFile = '~/.vimproj'
let g:ProjSplitMethod = 'edit '

" EasyGrep options:
let g:EasyGrepMode              = 2 " Track extension
let g:EasyGrepCommand           = 0 " vimgprep
let g:EasyGrepRecursive         = 1 " -> True
let g:EasyGrepReplaceWindowMode = 0 " At replace, open all in tabs
let g:EasyGrepExtraWarnings     = 1 " -> True

" TTags options:
let g:ttags_display = 'quickfix'

" Settings for Haskell mode:
let g:haddock_browser = "firefox"
let g:haddock_docdir = "/usr/share/doc/ghc/libraries/html/"

" Open all occurences of word under cursor in quickfix:
noremap [gI :execute 'vimgrep '.expand('<cword>').' '.expand('%')\|:copen\|:cc<cr>

" Yankring:
nnoremap <Leader>yr :YRShow<cr>

" Alignment mappings:
vmap <Leader>a=> :Align =><cr>

" Simpler tag searches:
command! -nargs=1 Function TTags f <args>
command! -nargs=1 Class    TTags c <args>

source ~/.local_vimrc
