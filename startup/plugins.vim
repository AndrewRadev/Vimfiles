" Prevent built-in tar and zip plugins from loading
let g:loaded_tarPlugin = 1
let g:loaded_tar       = 1
let g:loaded_zipPlugin = 1
let g:loaded_zip       = 1

" NERDTree:
let g:NERDTreeDirArrows   = 0
let g:NERDTreeHijackNetrw = 1
let g:NERDTreeIgnore      = [
      \ '\~$',
      \ '\.o$',
      \ '\.hi$'
      \ ]

" Don't map over J and K
let g:NERDTreeMapJumpFirstChild = '-'
let g:NERDTreeMapJumpLastChild  = '-'
" Don't care about cd-ing to the cwd
let g:NERDTreeMapCWD = '-'

" Snippet settings:
let g:snippets_dir = expand('~/.vim/snippets/')
let g:snips_author = 'Andrew Radev'

" Proj settings:
let g:ProjFile        = '~/.vimproj'
let g:ProjSplitMethod = 'edit '
let g:ProjFileBrowser = 'NERDTree | wincmd l'

" Omnicppcomplete options:
let OmniCpp_NamespaceSearch     = 1 " -> True
let OmniCpp_ShowPrototypeInAbbr = 1 " -> True
let OmniCpp_SelectFirstItem     = 2 " Select item, but don't insert
let OmniCpp_LocalSearchDecl     = 1 " Search regardless of bracket position
let OmniCpp_MayCompleteDot      = 1 " Automatically complete
let OmniCpp_MayCompleteArrow    = 1 " Automatically complete

" Ruby speedup
let g:ruby_path                      = ''
let g:rubycomplete_buffer_loading    = 0
let g:rubycomplete_classes_in_global = 0
let g:rubycomplete_rails             = 0

" get rid of custom rails syntax highlighting
let g:rails_syntax = 0

" syntax highlighting:
let ruby_operators = 1

" Avoid opening webpages in 'links':
let g:netrw_http_cmd = 'wget -q -O'

" Gist
let g:gist_open_browser_after_post = 1
let g:gist_browser_command         = 'firefox %URL% &'

" Javascript
let g:SimpleJsIndenter_BriefMode = 1
let g:jsl_config                 = '$HOME/.jsl'

" Command-line completion
cmap <C-j> <Plug>CmdlineCompletionBackward
cmap <C-k> <Plug>CmdlineCompletionForward

" Splitjoin
let g:splitjoin_split_mapping        = ''
let g:splitjoin_join_mapping         = ''
let g:splitjoin_normalize_whitespace = 1
let g:splitjoin_align                = 1

" Inline edit:
let g:inline_edit_autowrite  = 1
let g:inline_edit_proxy_type = 'tempfile'
let g:inline_edit_patterns   = [
      \   {
      \     'main_filetype':     '*html',
      \     'sub_filetype':      'handlebars',
      \     'indent_adjustment': 1,
      \     'start':             '<script\>[^>]*type="text/template"[^>]*>',
      \     'end':               '</script>',
      \   }
      \ ]

" Coffeescript
hi link coffeeSpaceError NONE
autocmd User CoffeeToolsPreviewOpened nnoremap <buffer> ! ZZ
let g:coffee_tools_default_mappings = 1

" Go
let g:go_highlight_trailing_whitespace_error = 0
" disable built-in commands in favor of my own
let g:go_import_commands = 0

" Ack.vim
" let g:ackprg = 'ag --nogroup --nocolor --column'
let g:ack_apply_qmappings = 0
let g:ack_apply_lmappings = 0

" LanguageTool
let g:languagetool_lang = 'de'

" Smartword
nmap w  <Plug>(smartword-w)
nmap b  <Plug>(smartword-b)
nmap e  <Plug>(smartword-e)
nmap ge <Plug>(smartword-ge)

xmap w  <Plug>(smartword-w)
xmap b  <Plug>(smartword-b)
xmap e  <Plug>(smartword-e)
xmap ge <Plug>(smartword-ge)

" Markdown
let g:markdown_fenced_languages = ['ruby', 'vim']

" Anzu
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" surround.vim
" Surround with function call
let g:surround_{char2nr('f')} = "FUNCTION(\r)"

" vim-exchange
let g:exchange_no_mappings = 1
nmap X <Plug>(Exchange)
xmap X <Plug>(Exchange)

" built-in HTML indenting
let g:html_indent_inctags = 'html,head,body,li,p'

" Writable search
let g:writable_search_backends = ['ack.vim', 'ack', 'egrep']

" Vim-pasta
let g:pasta_disabled_filetypes = ["python", "coffee", "markdown", "yaml", "slim", "haml", "txt"]
