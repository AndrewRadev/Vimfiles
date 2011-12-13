" Annoying, remove:
nnoremap s <Nop>
nnoremap Q <Nop>

" Easily mark a single line in character-wise visual mode
"xnoremap v <esc>0v$
nnoremap vv _vg_

" <space>x -> :X
" For easier typing of custom commands
nnoremap <space>      :call <SID>SpaceMapping(0)<cr>
xnoremap <space> :<c-u>call <SID>SpaceMapping(1)<cr>
function! s:SpaceMapping(visual)
  echo
  let c = nr2char(getchar())
  if a:visual
    normal! gv
  endif
  call feedkeys(':'.toupper(c))
endfunction

" Motion for "next/last object". For example, "din(" would go to the next "()" pair
" and delete its contents.
onoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
xnoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
onoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>
xnoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>
onoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
xnoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
onoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>
xnoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>
function! s:NextTextObject(motion, dir)
  let c = nr2char(getchar())

  if c ==# "b"
    let c = "("
  elseif c ==# "B"
    let c = "{"
  elseif c ==# "d"
    let c = "["
  endif

  exe "normal! ".a:dir.c."v".a:motion.c
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

" Upcase current word
nnoremap <C-u> mzgUiw`z

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
" Execute normal vim join if in visual mode
xnoremap sk J

" Inline edit
nnoremap ,e    :InlineEdit<cr>
inoremap <c-e> <esc>:InlineEdit<cr>

" Split and execute any command:
nnoremap __ :split \|<Space>

" Zoom current window in and out:
nnoremap ,, :ZoomWin<cr>

" Open new tab more easily:
nnoremap ,t :tabnew<cr>
nnoremap ,T :tabedit %<cr>gT:quit<cr>

" Standard 'go to manual' command
nmap gm :exe OpenURL('http://google.com/search?q=' . expand("<cword>"))<cr>

" Paste in insert and command modes
imap <C-p> <Esc>pa
cmap <C-p> <C-r>"

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
command! W call s:SudoWrite()
function! s:SudoWrite()
  write !sudo tee % >/dev/null
  e!
endfunction

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
nnoremap sa      :call <SID>TabularizeMapping(0)<cr>
xnoremap sa :<c-u>call <SID>TabularizeMapping(1)<cr>
function! s:TabularizeMapping(visual)
  echohl ModeMsg | echo "-- ALIGN -- "  | echohl None
  let align_type = nr2char(getchar())
  if align_type     == '='
    call s:Tabularize('equals', a:visual)
  elseif align_type == '>'
    call s:Tabularize('ruby_hash', a:visual)
  elseif align_type == ','
    call s:Tabularize('commas', a:visual)
  elseif align_type == ':'
    call s:Tabularize('colons', a:visual)
  elseif align_type == ' '
    call s:Tabularize('space', a:visual)
  else " just try aligning by the character
    call s:Tabularize('/'.align_type, a:visual)
  end
endfunction
function! s:Tabularize(command, visual)
  normal! mz

  let cmd = "Tabularize ".a:command
  if a:visual
    let cmd = "'<,'>" . cmd
  endif
  exec cmd
  echo

  normal! `z
endfunction

" Tabularize "reset" -- removes all duplicate whitespace
nnoremap s= :call <SID>TabularizeReset()<cr>
xnoremap s= :call <SID>TabularizeReset()<cr>
function! s:TabularizeReset()
  let original_cursor = getpos('.')

  s/\S\zs \+/ /g
  call histdel('search', -1)
  let @/ = histget('search', -1)

  call setpos('.', original_cursor)
endfunction

" Get rid of annoying register rewriting when pasting on visually selected
" text.
function! RestoreRegister()
  let @" = s:restore_reg
  let @* = s:restore_reg_star
  let @+ = s:restore_reg_plus
  return ''
endfunction
function! s:Repl()
  let s:restore_reg      = @"
  let s:restore_reg_star = @*
  let s:restore_reg_plus = @+
  return "p@=RestoreRegister()\<cr>"
endfunction
xnoremap <silent> <expr> p <SID>Repl()

" NERD tree:
nnoremap gn :NERDTreeToggle<cr>
nnoremap gN :NERDTree<cr>

nnoremap <Leader>f :NERDTreeFind<cr>
