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
" Refresh tags database
command! RefreshTags !ctags -R --sort=foldcase .

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap

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

" Instead of <C-o>, use <bs> to go back files:
nnoremap <bs> <C-o>

" Completion remappings:
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>

" Indent/Unindent:
nmap <Tab> >>
nmap <S-Tab> <<

" FindFile mappings:
nmap <C-f> :NERDTreeClose<Space>\|<Space>FF<cr>
imap <C-f> <Esc>:NERDTreeClose<Space>\|<Space>FF<cr>

" Dbext settings:
let g:dbext_default_buffer_lines = 30

" Showmarks settings:
let g:showmarks_ignore_type="hmpq"

" Snippet settings:
let g:snippets_dir = "~/.vim/custom_snippets/"
let g:snips_author = "Andrew Radev"

" Proj settings:
let g:ProjFile = '~/.vimproj'
let g:ProjSplitMethod = 'edit'

" For testing purposes:
let g:autotagVerbosityLevel = 2

" EasyGrep options:
let g:EasyGrepMode              = 1 " Don't track extension
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

" Settings for Haskell mode:
let g:haddock_browser = "firefox"
"let g:haddock_browser_callformat = '%s file://%s &> /dev/null &'
let g:haddock_docdir = '/usr/share/doc/ghc/libraries/html/'
