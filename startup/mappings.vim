" Annoying, remove:
nnoremap s <Nop>

" <space> for rails-related commands:
nnoremap <space>r :R
xnoremap <space>r :R
" <space> for git-related commands:
nnoremap <space>g :G
xnoremap <space>g :G

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

" For digraphs:
inoremap <C-n> <C-k>

" Cscope commands
nnoremap <C-n>s :lcs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-n>g :lcs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-n>c :lcs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-n>t :lcs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-n>e :lcs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap <C-n>f :lcs find f <C-R>=expand("<cfile>")<CR><CR>
nnoremap <C-n>i :lcs find i <C-R>=expand("<cfile>")<CR><CR>
nnoremap <C-n>d :lcs find d <C-R>=expand("<cword>")<CR><CR>

" Moving lines:
nnoremap <C-j> mz:m+<cr>`z
nnoremap <C-k> mz:m-2<cr>`z
xnoremap <C-j> :m'>+<cr>`<my`>mzgv`yo`z
xnoremap <C-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Easier increment/decrement:
nmap + <C-a>
nmap - <C-x>
" Swapit + speeddating
nmap <Plug>SwapItFallbackIncrement <Plug>SpeedDatingUp
nmap <Plug>SwapItFallbackDecrement <Plug>SpeedDatingDown

" Goto file or edit file:
nnoremap gF :exe "edit ".eval(&includeexpr)<cr>

" Alignment mappings:
xnoremap <Leader>a=> :Align =><cr>

" Easy split:
nnoremap <Leader><Leader> :split \|<Space>

" Comment in visual mode
xnoremap ,, :g/./normal ,,<cr>

" Standard 'go to manual' command
nmap gm :exe ":Utl ol http://google.com/search?q=" . expand("<cword>")<cr>

" Copying and pasting with the clipboard
nnoremap y "+y
xnoremap y "+y
nnoremap p "+p
nnoremap P "+P
xnoremap p "+p
nnoremap d "+d
xnoremap d "+d
nnoremap D "+D
xnoremap D "+D
nnoremap x "+x
xnoremap x "+x

" Paste in insert mode
imap <C-p> <Esc>pa
