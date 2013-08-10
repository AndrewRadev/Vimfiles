" Annoying, remove:
nnoremap s <Nop>
nnoremap Q <Nop>

" Easily mark a single line in character-wise visual mode
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
nnoremap <C-l> gt
nnoremap <C-h> gT

" Moving through splits:
nnoremap gh <C-w>h
nnoremap gj <C-w>j
nnoremap gk <C-w>k
nnoremap gl <C-w>l

" Faster scrolling:
nmap J 5j
nmap K 5k
xmap J 5j
xmap K 5k

" Toggle case of current word
nnoremap <C-u> mzg~iw`z

" Reindent whole file
nnoremap ++ :call lib#InPlace('normal! gg=G')<cr>

" Completion remappings:
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
inoremap <C-o> <C-x><C-o>
inoremap <C-u> <C-x><C-u>
inoremap <C-f> <C-x><C-f>
inoremap <C-]> <C-x><C-]>
inoremap <C-l> <C-x><C-l>
set completefunc=syntaxcomplete#Complete

" Use the last two typed characters to output a digraph.
inoremap <C-n> <esc>:call <SID>Digraph()<cr>a
function! s:Digraph()
  let col   = col('.')
  let chars = getline('.')[col - 2 : col - 1]

  exe "normal! s\<esc>s\<c-k>".chars
endfunction

" Splitting and joining code blocks
nnoremap sj :SplitjoinSplit<CR>
nnoremap sk :SplitjoinJoin<CR>
" Execute normal vim join if in visual mode
xnoremap sk J

" Moving code sideways
nnoremap s< :SidewaysLeft<CR>
nnoremap s> :SidewaysRight<CR>

" Inline edit
nnoremap ,e    :InlineEdit<cr>
xnoremap ,e    :InlineEdit<cr>
inoremap <c-e> <esc>:InlineEdit<cr>a

" Split and execute any command:
nnoremap __ :split \|<Space>

" Zoom current window in and out:
nnoremap ,, :ZoomWin<cr>

" Open new tab more easily:
nnoremap ,t :tabnew<cr>
nnoremap ,T :tabedit %<cr>gT:quit<cr>

" Standard 'go to manual' command
nnoremap gm :call Open('http://google.com/search?q=' . expand("<cword>"))<cr>

" Paste in insert and command modes
inoremap <C-p> <Esc>pa
cnoremap <C-p> <C-r>"

" Returns the cursor where it was before the start of the editing
runtime autoload/repeat.vim
nnoremap . mr:call repeat#run(v:count)<bar>call feedkeys('`r', 'n')<cr>

" Delete surrounding function call
" TODO doesn't work for method calls
" TODO relies on braces
nmap dsf F(bdt(ds(

" Quit tab, even if it's just one
nnoremap QQ :call <SID>QQ()<cr>
function! s:QQ()
  for bufnr in tabpagebuflist()
    if bufexists(bufnr)
      let winnr = bufwinnr(bufnr)
      exe winnr.'wincmd w'
      quit
    endif
  endfor
endfunction

" Run current file -- filetype-specific
nnoremap ! :Run<cr>

" Yank current file's filename
nnoremap gy :call <SID>YankFilename(1)<cr>
nnoremap gY :call <SID>YankFilename(0)<cr>
function! s:YankFilename(relative)
  let @@ = expand('%:p')

  if a:relative " then relativize it
    let @@ = fnamemodify(@@, ':~:.')
  endif

  let @* = @@
  let @+ = @@

  echo 'Yanked "'.@@.'" to clipboard'
endfunction

" Tabularize mappings
" For custom Tabularize definitions see after/plugin/tabularize.vim
nnoremap sa      :call <SID>Tabularize(0)<cr>
xnoremap sa :<c-u>call <SID>Tabularize(1)<cr>
function! s:Tabularize(visual)
  let saved_cursor = getpos('.')

  echohl ModeMsg | echo "-- ALIGN -- "  | echohl None
  let char = nr2char(getchar())

  if     char == '=' | let alignment = 'equals'
  elseif char == '>' | let alignment = 'ruby_hash'
  elseif char == ',' | let alignment = 'commas'
  elseif char == ':' | let alignment = 'colons'
  elseif char == ' ' | let alignment = 'space'
  else
    " just try aligning by the character
    let char = escape(char, '/')
    let alignment = '/'.char
  endif

  if a:visual
    exe "'<,'>Tabularize ".alignment
  else
    exe 'Tabularize '.alignment
  endif

  echo
  call setpos('.', saved_cursor)
endfunction

" Tabularize "reset" -- removes all duplicate whitespace
nnoremap s= :call <SID>TabularizeReset()<cr>
xnoremap s= :call <SID>TabularizeReset()<cr>
function! s:TabularizeReset()
  let original_cursor = getpos('.')

  s/\S\zs \+/ /ge
  call histdel('search', -1)
  let @/ = histget('search', -1)

  call setpos('.', original_cursor)
endfunction

" Get rid of annoying register rewriting when pasting on visually selected
" text.
"
" Note: magic
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

" Open path with external application
nnoremap gu :Open<cr>
xnoremap gu :Open<cr>

" Like "*", but for multiple files
nnoremap s* :call <SID>SearchWord(expand('<cword>'))<cr>
function! s:SearchWord(word)
  exe "Ack '\\b".a:word."\\b'"
endfunction

nnoremap - :Switch<cr>

" Duplicate lines
nnoremap zj mzyyP`z
nnoremap zk mzyyP`zk

" Duplicate blocks
nnoremap zJ :call <SID>DuplicateBlock('below')<cr>
nnoremap zK :call <SID>DuplicateBlock('above')<cr>
function! s:DuplicateBlock(direction)
  let start_lineno = line('.')
  let start_line   = getline(start_lineno)

  if start_line =~ '^\s*$'
    return
  endif

  let indent     = matchstr(start_line, '^\s*\ze\S')
  let end_lineno = nextnonblank(start_lineno + 1)
  let end_line   = getline(end_lineno)

  while end_lineno < line('$') && end_line !~ '^'.indent.'\S'
    let end_lineno = nextnonblank(end_lineno + 1)
    let end_line   = getline(end_lineno)
  endwhile

  let line_count = end_lineno - start_lineno + 1

  if line_count < 2
    return
  endif

  exe 'normal! y'.line_count.'y'

  if a:direction == 'below'
    exe end_lineno
    normal p
  else
    normal P
  endif
endfunction

" Show last search in quickfix (http://travisjeffery.com/b/2011/10/m-x-occur-for-vim/)
nmap g/ :vimgrep /<C-R>//j %<CR>\|:cw<CR>

" Use * without moving the cursor
" Note: g* is ordinarily taken
nnoremap g* :call <SID>SmartStar()<cr>
function! s:SmartStar()
  let cword = expand('<cword>')

  if cword == ''
    echo "No word under the cursor"
    return
  endif

  let current_col = col('.')

  call search('\<'.cword.'\>', 'bWc', line('.'))

  let cword_start_col = col('.')
  let cword_start     = strpart(cword, 0, current_col - cword_start_col)
  let cword_end       = strpart(cword, current_col - cword_start_col)

  let search_pattern = '\<\%('.cword_start.'\zs'.cword_end.'\)\>'

  call histadd('search', search_pattern)
  let @/ = search_pattern
  normal! n

  echo 'Search for: '.cword
endfunction

" Bufsurf
nnoremap <c-w>< :BufSurfBack<CR>
nnoremap <c-w>> :BufSurfForward<CR>

" Quicker text objects
onoremap " i"
onoremap ' i'
onoremap ( i(
onoremap [ i[
onoremap { i{

" Center result screen when searching
nnoremap n nzz
nnoremap N Nzz

" Quickly switch between / and ? when searching
cnoremap <expr> <c-l> <SID>CmdlineToggle("\<c-l>")
function! s:CmdlineToggle(default)
  let command_type = getcmdtype()

  if command_type != '/' && command_type != '?'
    return a:default
  endif

  let command_line     = getcmdline()
  let command_line_pos = getcmdpos()
  let other_mode       = (command_type == '/') ? '?' : '/'

  let search_command   = "\<c-c>".other_mode.command_line
  let position_command = "\<home>".repeat("\<right>", command_line_pos - 1)

  call feedkeys(search_command.position_command, 'n')
  return ''
endfunction

nnoremap dh :call <SID>DeleteAndDedent()<cr>
function! s:DeleteAndDedent()
  if !exists('b:dh_closing_pattern')
    echohl WarningMsg | echo "No b:dh_closing_pattern found for this buffer" | echohl NONE
    return
  end

  let start_lineno = line('.')
  let start_indent = indent(start_lineno)

  let current_lineno = nextnonblank(start_lineno + 1)

  while current_lineno < line('$') && indent(current_lineno) > start_indent
    if indent(current_lineno) == indent(start_lineno)
      let end_lineno = current_lineno
      break
    endif

    let current_lineno = nextnonblank(current_lineno + 1)
  endwhile

  let end_lineno = current_lineno

  if indent(end_lineno) == indent(start_lineno) &&
        \ getline(end_lineno) =~ b:dh_closing_pattern
    " then it's probably a block-closer, delete it
    exe end_lineno.'delete _'
  endif

  if end_lineno - start_lineno > 1
    exe (start_lineno + 1).','.(end_lineno - 1).'<'
  endif

  exe start_lineno.'delete'
  echo
endfunction
