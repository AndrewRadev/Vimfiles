" NERD tree:
nmap gn :NERDTreeToggle<cr>
nmap gN :NERDTree<cr>

nmap <Leader>f :NERDTreeFind<cr>

let g:NERDTreeHijackNetrw = 1
let g:NERDTreeIgnore = [
      \ '\~$',
      \ '\.o$',
      \ '\.hi$'
      \ ]

" Open up fuzzy finder:
nmap Qt :CommandT<cr>

" Dbext settings:
let g:dbext_default_buffer_lines  = 20
let g:dbext_default_replace_title = 1
let g:dbext_default_history_file  = '~/.dbext_history'

" Snippet settings:
let g:snippets_dir = expand("~/.vim/custom_snippets/")
let g:snips_author = "Andrew Radev"

" Proj settings:
let g:ProjFile        = '~/.vimproj'
let g:ProjSplitMethod = 'edit '
let g:ProjFileBrowser = 'NERDTree | wincmd l'

" EasyGrep options:
let g:EasyGrepMode              = 2 " Track extension
let g:EasyGrepCommand           = 0 " vimgrep
let g:EasyGrepRecursive         = 1 " -> True
let g:EasyGrepReplaceWindowMode = 0 " At replace, open all in tabs
let g:EasyGrepExtraWarnings     = 1 " -> True

" TTags options:
let g:ttags_display = 'quickfix'

" Settings for Haskell mode:
let g:haddock_browser = "firefox"
let g:haddock_docdir  = "/usr/share/doc/ghc/html/libraries/"

" Omnicppcomplete options:
let OmniCpp_NamespaceSearch     = 1 " -> True
let OmniCpp_ShowPrototypeInAbbr = 1 " -> True
let OmniCpp_SelectFirstItem     = 2 " Select item, but don't insert
let OmniCpp_LocalSearchDecl     = 1 " Search regardless of bracket position
let OmniCpp_MayCompleteDot      = 1 " Automatically complete
let OmniCpp_MayCompleteArrow    = 1 " Automatically complete

" Ruby omnicomplete:
" TODO: Still slow as hell
let g:rubycomplete_buffer_loading    = 0
let g:rubycomplete_classes_in_global = 0
let g:rubycomplete_rails             = 0

" syntax highlighting:
let ruby_no_expensive = 1
let ruby_operators = 1

" Avoid opening webpages in 'links':
let g:netrw_http_cmd	= "wget -q -O"

" Command-line word completion
cmap <c-k> <Plug>CmdlineCompleteBackward
cmap <c-j> <Plug>CmdlineCompleteForward

" Calendar:
let g:calendar_monday = 1

" QuickRun:
let g:quickrun_config = {
      \ '*': { 'split': 'rightbelow' }
      \ }

nnoremap <bs> :BufSurfBack<cr>
nnoremap <C-i> :BufSurfForward<cr>

let g:gist_open_browser_after_post = 1
let g:gist_browser_command         = 'firefox %URL% &'
