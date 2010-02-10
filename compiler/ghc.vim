" Vim Compiler File
" Compiler:	GHC
" Maintainer:	Claus Reinke <claus.reinke@talk21.com>
" Last Change:	30/04/2009
"
" part of haskell plugins: http://projects.haskell.org/haskellmode-vim

" ------------------------------ paths & quickfix settings first
"

if exists("current_compiler") && current_compiler == "ghc"
  finish
endif
let current_compiler = "ghc"

let s:scriptname = "ghc.vim"

if (!exists("g:ghc") || !executable(g:ghc))
  if !executable('ghc')
    echoerr s:scriptname.": can't find ghc. please set g:ghc, or extend $PATH"
    finish
  else
    let g:ghc = 'ghc'
  endif
endif
let ghc_version = substitute(system(g:ghc . ' --numeric-version'),'\n','','')
if (!exists("b:ghc_staticoptions"))
  let b:ghc_staticoptions = ''
endif

" set makeprg (for quickfix mode)
execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
"execute 'setlocal makeprg=' . g:ghc .'\ -e\ :q\ %'
"execute 'setlocal makeprg=' . g:ghc .'\ --make\ %'

" quickfix mode:
" fetch file/line-info from error message
" TODO: how to distinguish multiline errors from warnings?
"       (both have the same header, and errors have no common id-tag)
"       how to get rid of first empty message in result list?
setlocal errorformat=
                    \%-Z\ %#,
                    \%W%f:%l:%c:\ Warning:\ %m,
                    \%E%f:%l:%c:\ %m,
                    \%E%>%f:%l:%c:,
                    \%+C\ \ %#%m,
                    \%W%>%f:%l:%c:,
                    \%+C\ \ %#%tarning:\ %m,

" oh, wouldn't you guess it - ghc reports (partially) to stderr..
setlocal shellpipe=2>

" ------------------------- but ghc can do a lot more for us..
"

" allow map leader override
if !exists("maplocalleader")
  let maplocalleader='_'
endif

" initialize map of identifiers to their types
" associate type map updates to changedtick
if !exists("b:ghc_types")
  let b:ghc_types = {}
  let b:my_changedtick = b:changedtick
endif

if exists("g:haskell_functions")
  finish
endif
let g:haskell_functions = "ghc"

" avoid hit-enter prompts
"set cmdheight=3

" edit static GHC options
" TODO: add completion for options/packages?
command! GHCStaticOptions call ghc#StaticOptions()

map <LocalLeader>T :call ghc#ShowType(1)<cr>
map <LocalLeader>t :call ghc#ShowType(0)<cr>

" show type of identifier under mouse pointer in balloon
if has("balloon_eval")
  set ballooneval
  set balloondelay=600
  set balloonexpr=ghc#TypeBalloon()
endif

map <LocalLeader>si :call ghc#ShowInfo()<cr>

" update b:ghc_types after successful make
au QuickFixCmdPost make if ghc#CountErrors()==0 | silent call ghc#BrowseAll() | endif


command! GHCReload call ghc#BrowseAll()

let s:ghc_templates = ["module _ () where","class _ where","class _ => _ where","instance _ where","instance _ => _ where","type family _","type instance _ = ","data _ = ","newtype _ = ","type _ = "]

set omnifunc=ghc#CompleteImports
"
" Vim's default completeopt is menu,preview
" you probably want at least menu, or you won't see alternatives listed
" setlocal completeopt+=menu

" menuone is useful, but other haskellmode menus will try to follow your choice here in future
" setlocal completeopt+=menuone

" longest sounds useful, but doesn't seem to do what it says, and interferes with CTRL-E
" setlocal completeopt-=longest

map <LocalLeader>ct :call ghc#CreateTagfile()<cr>

command! -nargs=1 GHCi redraw | echo system(g:ghc. ' ' . b:ghc_staticoptions .' '.expand("%").' -e "'.escape(<f-args>,'"').'"')

" use :make 'not in scope' errors to explicitly list imported ids
" cursor needs to be on import line, in correctly loadable module
map <LocalLeader>ie :call ghc#MkImportsExplicit()<cr>

if ghc#VersionGE([6,8,2])
  let opts = filter(split(substitute(system(g:ghc . ' -v0 --interactive', ':set'), '  ', '','g'), '\n'), 'v:val =~ "-f"')
else
  let opts = ["-fglasgow-exts","-fallow-undecidable-instances","-fallow-overlapping-instances","-fno-monomorphism-restriction","-fno-mono-pat-binds","-fno-cse","-fbang-patterns","-funbox-strict-fields"]
endif

amenu ]OPTIONS_GHC.- :echo '-'<cr>
aunmenu ]OPTIONS_GHC
for o in opts
  exe 'amenu ]OPTIONS_GHC.'.o.' :call append(0,"{-# OPTIONS_GHC '.o.' #-}")<cr>'
endfor
if has("gui_running")
  map <LocalLeader>opt :popup ]OPTIONS_GHC<cr>
else
  map <LocalLeader>opt :emenu ]OPTIONS_GHC.
endif

amenu ]LANGUAGES_GHC.- :echo '-'<cr>
aunmenu ]LANGUAGES_GHC
if ghc#VersionGE([6,8])
  let ghc_supported_languages = split(system(g:ghc . ' --supported-languages'),'\n')
  for l in ghc_supported_languages
    exe 'amenu ]LANGUAGES_GHC.'.l.' :call append(0,"{-# LANGUAGE '.l.' #-}")<cr>'
  endfor
  if has("gui_running")
    map <LocalLeader>lang :popup ]LANGUAGES_GHC<cr>
  else
    map <LocalLeader>lang :emenu ]LANGUAGES_GHC.
  endif
endif
