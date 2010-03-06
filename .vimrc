set nocompatible

filetype plugin on
filetype indent on
syntax on

colo custom_elflord

" Load settings:
runtime! startup/basic.vim
runtime! startup/autocommands.vim
runtime! startup/utl.vim
runtime! startup/smartword.vim
runtime! startup/search.vim
runtime! startup/visual_search.vim
runtime! startup/plugins.vim
runtime! startup/commands.vim

" Toggle settings:
command! -nargs=+ MapToggle call lib#MapToggle(<f-args>)

" Edit important files quickly:
command! Eclipboard ClipBrd
command! Epasswords edit ~/.passwords

" Rebuild tags database:
command! RebuildTags !ctags -R .

" Refresh snippets
command! RefreshSnips runtime after/plugin/snippets.vim

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

" Moving lines:
nnoremap <C-j> mz:m+<cr>`z
nnoremap <C-k> mz:m-2<cr>`z
xnoremap <C-j> :m'>+<cr>`<my`>mzgv`yo`z
xnoremap <C-k> :m'<-2<cr>`>my`<mzgv`yo`z

function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
xnoremap <silent> <expr> p <sid>Repl()

" Goto file or edit file:
nnoremap gF :exe "edit ".eval(&includeexpr)<cr>

" Indent some additional html tags:
let g:html_indent_tags = 'p\|li'

" For digraphs:
inoremap <C-n> <C-k>

" <Tab> with folds:
nnoremap <Tab> zA

" Open all occurences of word under cursor in quickfix:
nnoremap [gI :execute 'vimgrep '.expand('<cword>').' '.expand('%')\|:copen\|:cc<cr>

" Alignment mappings:
xnoremap <Leader>a=> :Align =><cr>

" Easy split:
nnoremap <Leader><Leader> :split \|

" Comment in visual mode
xnoremap ,, :g/./normal ,,<cr>

source ~/.local_vimrc
