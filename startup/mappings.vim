" Annoying, remove:
nnoremap s <Nop>
nnoremap Q <Nop>

" Easily mark a single line in character-wise visual mode
"xnoremap v <esc>0v$
nnoremap vv _v$h

" <space>x -> :X
" For easier typing of custom commands
noremap <space> :call <SID>SpaceMapping()<cr>
function! s:SpaceMapping()
  echo
  let c = nr2char(getchar())
  call feedkeys(':'.toupper(c))
endfunction

" Always move through visual lines:
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" Moving through tabs:
nmap <C-l> gt
nmap <C-h> gT

" Moving through splits:
nmap gh <C-w>h
nmap gj <C-w>j
nmap gk <C-w>k
nmap gl <C-w>l

" Faster scrolling:
nmap J 5j
nmap K 5k
xmap J 5j
xmap K 5k

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

" Goto file or edit file (not working most times...):
nnoremap gF :exe "edit ".eval(&includeexpr)<cr>

" Alignment mappings:
xnoremap <Leader>a=> :Align =><cr>

" Easy split:
nnoremap <Leader><Leader> :split \|<Space>

" Standard 'go to manual' command
nmap gm :exe ":Utl ol http://google.com/search?q=" . expand("<cword>")<cr>

" Paste in insert mode
imap <C-p> <Esc>pa

" Returns the cursor where it was before the start of the editing
nmap . .`[

" See startup/commands.vim
nnoremap QQ :Q<cr>

" Run current file -- filetype-specific
nnoremap ! :Run<cr>
xnoremap ! :Run<cr>

" Yank current file's filename
nnoremap gy :call <SID>YankFilename(0)<cr>
nnoremap gY :call <SID>YankFilename(1)<cr>
function! s:YankFilename(linewise)
  let @@ = expand('%:p')

	if (a:linewise) " then add a newline at end
    let @@ .= "\<nl>"
  endif

  let @* = @@
  let @+ = @@

  echo "Yanked filename in clipboard"
endfunction

" SimpleFold mapping
map <Leader>z <Plug>SimpleFold_Foldsearch

" Temporary VimTree mapping
noremap ,, :VimTreeToggle<cr>
