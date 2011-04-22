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

" Moving lines up and down:
nnoremap <C-j> :m+<CR>==
nnoremap <C-k> :m-2<CR>==
xnoremap <C-j> :m'>+<CR>gv=gv
xnoremap <C-k> :m-2<CR>gv=gv

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

" Splitting and joining code blocks
nnoremap sj :SplitjoinSplit<CR>
nnoremap sk :SplitjoinJoin<CR>

" Easier increment/decrement:
nmap + <C-a>
nmap - <C-x>

" Easy split:
nnoremap __ :split \|<Space>

" Easy ZoomWin:
nnoremap ,, :ZoomWin<cr>

" Open new tab more easily:
nnoremap ,t :tabnew<cr>

" Standard 'go to manual' command
nmap gm :exe ":Utl ol http://google.com/search?q=" . expand("<cword>")<cr>

" Paste in insert mode
imap <C-p> <Esc>pa

" Returns the cursor where it was before the start of the editing
nmap . .`[

" Delete surrounding function call
" TODO doesn't work for method calls
" TODO relies on braces
nmap dsf F(bdt(ds(

" See startup/commands.vim
nnoremap QQ :Q<cr>

" https://github.com/bjeanes/dot-files/blob/master/vim/vimrc
" For when you forget to sudo.. Really Write the file.
command! W write !sudo tee % >/dev/null

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

" Tabularize mappings
" For custom Tabularize definitions see after/plugin/tabularize.vim

nnoremap sa :call <SID>TabularizeMapping()<cr>
function! s:TabularizeMapping()
  echo "Align >> "
  let align_type = nr2char(getchar())
  if align_type     == '='
    call s:Tabularize('equals')
  elseif align_type == '>'
    call s:Tabularize('ruby_hash')
  elseif align_type == ','
    call s:Tabularize('commas')
  elseif align_type == ':'
    call s:Tabularize('colons')
  end
endfunction
function! s:Tabularize(command)
  normal! mz
  exec "Tabularize ".a:command
  normal! `z
endfunction

" one   = two
" three = four
nnoremap <Leader>t= mz:Tabularize equals<cr>`z
xnoremap <Leader>t= mz:Tabularize equals<cr>`z

" one   => two
" three => four
nnoremap <Leader>t> mz:Tabularize ruby_hash<cr>`z
xnoremap <Leader>t> mz:Tabularize ruby_hash<cr>`z

" one,   two,  three
" three, four, five
nnoremap <Leader>t, mz:Tabularize commas<cr>`z
xnoremap <Leader>t, mz:Tabularize commas<cr>`z

" one:   two
" three: four
nnoremap <Leader>t: mz:Tabularize colons<cr>`z
xnoremap <Leader>t: mz:Tabularize colons<cr>`z
