" NERD tree:
nmap gn :NERDTreeToggle<cr>
nmap gN :NERDTree<cr>

nmap <Leader>f :NERDTreeFind<cr>

let g:NERDTreeHijackNetrw = 0
let g:NERDTreeIgnore = [
      \ '\~$',
      \ '\.o$',
      \ '\.hi$'
      \ ]

" Open up FuzzyFinders:
nmap Qf :FuzzyFinderTextMate<cr>
nmap Qm :FuzzyFinderMruFile<cr>

nmap Qt :CommandT<cr>

" FuzzyFinderTextMate settings:
let g:fuzzy_ceiling = 20000
let g:fuzzy_ignore  = "*/.svn/*;.git/*;*/tmp/*"

" Dbext settings:
let g:dbext_default_buffer_lines = 20

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

" Autocomplete options:
let g:acp_enableAtStartup    = 1 " Enable
let g:acp_ignorecaseOption   = 0 " Don't ignore case, that's annoying
let g:acp_behaviorFileLength = 2 " Speed up?

" SVN Sandbox plugin:
let g:sandbox_use_vcscommand   = 1
let g:sandbox_look_for_updates = 0

" Ruby omnicomplete:
let g:rubycomplete_buffer_loading    = 0
let g:rubycomplete_classes_in_global = 0
let g:rubycomplete_rails             = 0

" Avoid opening webpages in links:
let g:netrw_http_cmd	= "wget -q -O"

" Calendar:
let g:calendar_monday = 1
