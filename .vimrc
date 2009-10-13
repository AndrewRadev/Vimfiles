set nocompatible

filetype plugin on
filetype indent on
syntax on

colo custom_elflord

" Load settings:
runtime! startup/basic.vim
runtime! startup/autocommands.vim
runtime! startup/utl.vim

" Toggle settings:
command! -nargs=+ MapToggle call lib#MapToggle(<f-args>)

" Align by columns:
command! -range AlignSpace <line1>,<line2>call lib#AlignSpace()

" Edit file in clipboard:
command! Eclipboard edit `=@*`

" Rebuild tags database:
command! RebuildTags !ctags -R --sort=foldcase .

" Generic console, override in different filetypes:
command! Console shell

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap

" To avoid unexpected behaviour, remove the <s> mapping entirely:
nnoremap s <Nop>

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

" Toggling the NERD tree:
nmap gn :NERDTreeToggle<cr>
nmap gN :NERDTree<cr>

let g:NERDTreeHijackNetrw = 0

" Open up FuzzyFinders:
nmap Qf :FuzzyFinderTextMate<cr>
nmap Qm :FuzzyFinderMruFile<cr>

" Instead of <C-o>, use <bs> to go back files:
nnoremap <bs> <C-o>

" Completion remappings:
"inoremap <C-j> <C-n> "should learn to use the defaults
"inoremap <C-k> <C-p>
inoremap <C-o> <C-x><C-o>
inoremap <C-u> <C-x><C-u>
inoremap <C-f> <C-x><C-f>
inoremap <C-]> <C-x><C-]>
set completefunc=syntaxcomplete#Complete

" Indent/Unindent:
nmap <Tab> >>
nmap <S-Tab> <<

" Dbext settings:
let g:dbext_default_buffer_lines = 30

" Snippet settings:
let g:snippets_dir = "~/.vim/custom_snippets/"
let g:snips_author = "Andrew Radev"

" FuzzyFinderTextMate settings:
let g:fuzzy_ceiling = 20000
let g:fuzzy_ignore = "*/.svn/*;.git/*"

" Proj settings:
let g:ProjFile = '~/.vimproj'
let g:ProjSplitMethod = 'edit'

" EasyGrep options:
let g:EasyGrepMode              = 0 " Don't track extension
let g:EasyGrepCommand           = 0 " vimgprep
let g:EasyGrepRecursive         = 1 " -> True
let g:EasyGrepReplaceWindowMode = 0 " At replace, open all in tabs
let g:EasyGrepExtraWarnings     = 1 " -> True

" AutoTags options:
let g:autotagCtagsCmd = "ctags --sort=foldcase"

" TTags options:
let g:ttags_display = 'quickfix'

" Settings for Haskell mode:
let g:haddock_browser = "firefox"
let g:haddock_docdir = '/usr/share/doc/ghc/libraries/html/'
