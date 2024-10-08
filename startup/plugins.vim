packadd matchit

" NERDTree:
let g:NERDTreeHijackNetrw = 0
let g:NERDTreeIgnore      = [
      \ '\~$',
      \ '\.o$',
      \ '\.hi$',
      \ '\.class$',
      \ ]

" Don't map over J and K
let g:NERDTreeMapJumpFirstChild = '-'
let g:NERDTreeMapJumpLastChild  = '-'
" Don't care about cd-ing to the cwd
let g:NERDTreeMapCWD = '-'
" The 's' key is a prefix for a lot of things
let g:NERDTreeMapOpenVSplit = 'so'
" I use 'go' for something else and don't use it in the NERDTree
let g:NERDTreeMapPreview = '-'

" Snippet settings:
let g:snips_author = 'Andrew Radev'

" Proj settings:
let g:ProjDisableMappings = 1
let g:ProjSplitMethod     = 'edit '
let g:ProjFileBrowser     = 'NERDTree | wincmd l'

" Ruby settings
let g:ruby_path                      = ''
let g:rubycomplete_rails             = 0
let g:rubycomplete_buffer_loading    = 1
let g:rubycomplete_classes_in_global = 1
let g:ruby_operators                 = 1

" Python settings
let g:python_indent = {
      \ 'open_paren':                   'shiftwidth()',
      \ 'nested_paren':                 'shiftwidth()',
      \ 'continue':                     'shiftwidth()',
      \ 'closed_paren_align_last_line': v:false,
      \ }

" get rid of custom rails syntax highlighting
let g:rails_syntax = 0

" Avoid opening webpages in 'links':
let g:netrw_http_cmd = 'wget -q -O'
" Don't use netrw at all, attaches BufEditCmd handlers for URLs
let g:loaded_netrwPlugin = 1

" Gist
let g:gist_open_browser_after_post = 1
let g:gist_browser_command         = 'firefox %URL% &'

" Splitjoin
let g:splitjoin_split_mapping                           = ''
let g:splitjoin_join_mapping                            = ''
let g:splitjoin_normalize_whitespace                    = 1
let g:splitjoin_align                                   = 1
let g:splitjoin_ruby_hanging_args                       = 0
let g:splitjoin_trailing_comma                          = 1
let g:splitjoin_handlebars_closing_bracket_on_same_line = 1
let g:splitjoin_handlebars_hanging_arguments            = 1
let g:splitjoin_python_brackets_on_separate_lines       = 1

" Inline edit:
let g:inline_edit_autowrite  = 1
let g:inline_edit_proxy_type = 'tempfile'

" Coffeescript
hi link coffeeSpaceError NONE
autocmd User CoffeeToolsPreviewOpened nnoremap <buffer> ! ZZ
let g:coffee_tools_default_mappings = 1
let g:coffee_tools_function_text_object = 0

" Go
let g:go_highlight_trailing_whitespace_error = 0

" Ack.vim
" let g:ackprg = 'ag --nogroup --nocolor --column'
" let g:ackprg = 'rg --vimgrep'
let g:ack_apply_qmappings = 0
let g:ack_apply_lmappings = 0

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
let g:markdown_fenced_languages = ['ruby', 'vim', 'rust', 'bash']

" surround.vim
xmap s S

" vim-exchange
let g:exchange_no_mappings = 1
nmap X <Plug>(Exchange)
xmap X <Plug>(Exchange)

" built-in HTML indenting
let g:html_indent_inctags = 'html,head,body,li,p'
" For :TOhtml
let g:html_font = "Fantasque Sans Mono"

" Writable search
let g:writable_search_backends = ['ack.vim', 'ack', 'egrep']
let g:writable_search_confirm_file_rename = 0
let g:writable_search_confirm_directory_creation = 0

" Vim-pasta
let g:pasta_disabled_filetypes = [
      \ "python", "coffee", "markdown",
      \ "yaml", "slim", "haml", "txt",
      \ "emblem"
      \ ]

" Multichange
let g:multichange_mapping        = 'sm'
let g:multichange_motion_mapping = 'm'
let g:multichange_save_position  = 1

" Switch
nmap - <Plug>(Switch)

" RengBang
let g:rengbang_default_start = 1

" CSV
let g:csv_nomap_j     = 1
let g:csv_nomap_k     = 1
let g:csv_nomap_space = 1

" Andrew's NERDTree
let g:andrews_nerdtree_all                  = 1
let g:andrews_nerdtree_external_open_key    = 'gu'
" let g:andrews_nerdtree_quickfix_filter_auto = 1

" Colorizer
let g:colorizer_nomap = 1
let g:colorizer_startup = 0

" Deleft
let g:deleft_remove_strategy = 'delete'

" UltiSnips
let g:UltiSnipsSnippetDirectories = ['ultisnips']
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsNoPythonWarning = 1

" http-request
let g:http_client_bind_hotkey = 0
let g:http_client_json_ft = 'json'
let g:http_client_result_vsplit = 0

command! HttpRequest HTTPClientDoRequest

" Tagalong
let g:tagalong_verbose = 1

" Mundo
let g:mundo_right = 1
let g:mundo_auto_preview_delay = 150
let g:mundo_inline_undo = 1

" Tcomment
let g:tcomment_maps = 0
nmap <c-_><c-_> <Plug>TComment_<c-_><c-_>
xmap <c-_><c-_> <Plug>TComment_<c-_><c-_>

" Loclist-follow: disabled for now, need to debug performance issues
let g:loclist_follow = 0

" Silicon
let g:silicon = #{
      \ theme:                'Dracula',
      \ font:                 'Fantasque Sans Mono',
      \ background:           '#aaaacc',
      \ shadow-color:         '#555555',
      \ line-pad:             2,
      \ pad-horiz:            30,
      \ pad-vert:             40,
      \ shadow-blur-radius:   0,
      \ shadow-offset-x:      0,
      \ shadow-offset-y:      0,
      \ line-number:          v:true,
      \ round-corner:         v:true,
      \ window-controls:      v:true,
      \ default-file-pattern: '~/images/shots/{time:%Y-%m-%d-%H%M%S}-silicon.png'
      \ }

" Http
let g:vim_http_clean_before_do = 0
let g:vim_http_tempbuffer      = 1

" JSON
let g:vim_json_syntax_conceal = 0

" Pickachu
let g:pickachu_default_date_format = "%Y-%m-%d"

" JSX
let g:vim_jsx_pretty_colorful_config = 1

" Yankwin
let g:yankwin_clipboard = "unnamed,unnamedplus"

" Git-msg-wheel
let g:git_msg_wheel_list_show = 0 " hide list

" Colddeck
let g:cdeck_nomaps = 1

" Rails Extra
let g:rails_extra_debug = 1

" Deal with it
let g:dealwithit_guifont = 'Fantasque Sans Mono 8'
let g:dealwithit_sleep = 0

" Prettier
let g:prettier#autoformat = 0

" Popup scrollbar
let g:popup_scrollbar_auto = 1
let g:popup_scrollbar_shape = {
      \ 'head': '∧',
      \ 'body': '┃',
      \ 'tail': '∨',
      \ }

" Strftime
imap <c-x><c-d> <Plug>StrftimeComplete

" Rust settings:
" Don't define global cargo commands
let g:loaded_rust_vim_plugin_cargo = 1
