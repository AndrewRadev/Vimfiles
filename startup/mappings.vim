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
  echo "Jump to next motion: "
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
nnoremap <silent> j gj
nnoremap <silent> k gk
xnoremap <silent> j gj
xnoremap <silent> k gk

" Moving through tabs:
nnoremap <C-l> gt
nnoremap <C-h> gT

" Moving through splits:
nnoremap gh <C-w>h
nnoremap gj <C-w>j
nnoremap gk <C-w>k
nnoremap gl <C-w>l

" Faster scrolling:
nnoremap <silent> J 5gj
nnoremap <silent> K 5gk
xnoremap <silent> J 5gj
xnoremap <silent> K 5gk

" Resize windows
nnoremap <left>  <c-w><
nnoremap <right> <c-w>>
nnoremap <up>    <c-w>-
nnoremap <down>  <c-w>+

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
nmap <silent> sj <Plug>SplitjoinSplit
nmap <silent> sk <Plug>SplitjoinJoin
" Execute normal vim join if in visual mode
xnoremap sk J

" Sideways: moving
nnoremap s< :SidewaysLeft<CR>
nnoremap s> :SidewaysRight<CR>

" Sideways: argument text object
omap <silent> aa <Plug>SidewaysArgumentTextobjA
xmap <silent> aa <Plug>SidewaysArgumentTextobjA
omap <silent> ia <Plug>SidewaysArgumentTextobjI
xmap <silent> ia <Plug>SidewaysArgumentTextobjI

" Sideways: add new argument
nmap ,si <Plug>SidewaysArgumentInsertBefore
nmap ,sa <Plug>SidewaysArgumentAppendAfter
nmap ,sI <Plug>SidewaysArgumentInsertFirst
nmap ,sA <Plug>SidewaysArgumentAppendLast

" Inline edit
nnoremap ,e :InlineEdit<cr>
xnoremap ,e :InlineEdit<cr>

" Split and execute any command:
nnoremap __ :split \|<Space>
" Tab-split and execute
nnoremap _t :tab split \|<Space>

" Open new tab more easily:
nnoremap ,t :tabnew<cr>
nnoremap ,T mt:tabedit %<cr>`tgT:quit<cr>

" Standard 'go to manual' command
nnoremap gm :call Open('https://duckduckgo.com/?q=' . expand("<cword>"))<cr>

" Paste in insert and command modes
inoremap <C-p> <Esc>pa
cnoremap <C-p> <C-r>"

" Returns the cursor where it was before the start of the editing
runtime autoload/repeat.vim
nnoremap <silent> . mr:call repeat#run(v:count)<bar>call feedkeys('`r', 'n')<cr>

" Quit tab, even if it's just one
nnoremap <silent> QQ :call <SID>QQ()<cr>
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
    let char = escape(char, '/.')
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

" NERD tree:
nnoremap gn :NERDTreeToggle<cr>
nnoremap gN :NERDTree<cr>

nnoremap <Leader>f :NERDTreeFind<cr>

" Toggle quickfix
" Note: can't use :cwindow, only closes if there's nothing there.
" Note: probably doesn't handle location list well
nnoremap <silent> go :call <SID>ToggleQuickfix()<cr>
function! s:ToggleQuickfix()
  for n in range(1, winnr('$'))
    if getwinvar(n, '&buftype') == 'quickfix'
      " quickfix buffer found in tab, close
      cclose
      return
    endif
  endfor

  " no quickfix found, open it
  copen
endfunction

" Open path with external application
nnoremap gu :Open<cr>
xnoremap gu :Open<cr>

" Like "*", but for multiple files
nnoremap s* :call <SID>SearchWord(expand('<cword>'))<cr>
function! s:SearchWord(word)
  let position = getpos('.')
  let active_window = winnr()

  exe 'Ack \b'.a:word.'\b'

  exe active_window.'wincmd w'
  cclose

  let qflist = getqflist()

  if len(qflist) == 0
    " nevermind, nothing was found (probably impossible)
    return
  endif

  let active_item = qflist[0]
  let active_index = 0

  if len(qflist) > 1 && position == getpos('.')
    " this is the place we started from, jump to the next one
    let active_index = 1
    silent cnext
  endif

  echo "Ack: Result ".(active_index + 1)." of ".len(qflist)
endfunction

" Show last search in quickfix (http://travisjeffery.com/b/2011/10/m-x-occur-for-vim/)
nnoremap g/ :vimgrep /<C-R>//j %<CR>\|:cw<CR>

" Bufsurf
nnoremap <c-w>< :BufSurfBack<CR>
nnoremap <c-w>> :BufSurfForward<CR>

" Quickly switch between / and ? when searching
cnoremap <expr> <c-l> <SID>CmdlineToggle()
function! s:CmdlineToggle() abort
  let command_type = getcmdtype()
  if command_type != '/' && command_type != '?'
    return ''
  endif

  let command_line     = getcmdline()
  let command_line_pos = getcmdpos()
  let other_mode       = (command_type == '/') ? '?' : '/'

  let search_command   = "\<c-c>"..other_mode..command_line
  let position_command = "\<home>"..repeat("\<right>", command_line_pos - 1)

  call feedkeys(search_command..position_command, 'n')
  return ''
endfunction

" Easily switch to very magic mode in a search
" TODO switch back to magic?
cnoremap <expr> <c-y> <SID>VeryMagicToggle()
function! s:VeryMagicToggle() abort
  let command_type = getcmdtype()
  if command_type != '/' && command_type != '?'
    return ''
  endif

  let command_line = getcmdline()
  if command_line =~# '^\\v'
    " already in very magic mode, nothing to do
    return ''
  endif

  let very_magic_command_line = '\v' .. substitute(command_line, '\\\(\W\)', '\1', 'g')

  let command_line_pos = getcmdpos()
  let search_command   = "\<c-u>"..very_magic_command_line
  let position_command = "\<home>"..repeat("\<right>", command_line_pos - 1)

  call feedkeys(search_command..position_command, 'n')
  return ''
endfunction

" Change between `method arg1, arg2` and `method(arg1, arg2)`
nnoremap g( :Repeatable call <SID>ToggleBrackets()<cr>
nnoremap g) :Repeatable call <SID>ToggleBrackets()<cr>
function! s:ToggleBrackets()
  let [_, arguments] = sideways#Parse()
  if empty(arguments)
    return
  endif

  let saved_view = winsaveview()

  let start_lineno = arguments[0].start_line
  let start_line   = getline(start_lineno)
  let end_lineno   = arguments[-1].end_line
  let end_line     = getline(end_lineno)

  let start_col       = arguments[0].start_col
  let start_col_index = start_col - 1
  let end_col         = arguments[-1].end_col
  let end_col_index   = end_col - 1

  let saved_wrap = &wrap
  set nowrap

  if start_line[start_col_index - 1] == '(' && end_line[end_col_index + 1] == ')'
    exe "normal! ".(start_lineno)."G"
    exe "normal! ".(start_col - 1)."|r\<space>"

    exe "normal! ".(end_lineno)."G"
    exe "normal! ".(end_col + 1)."|x"
  elseif start_line[start_col_index - 1] == ' '
    exe "normal! ".(start_lineno)."G"
    exe "normal! ".(start_col - 1)."|r("

    exe "normal! ".(end_lineno)."G"
    exe "normal! ".(end_col)."|a)"
  endif

  let &wrap = saved_wrap

  call winrestview(saved_view)
endfunction

" Delete left-hand side of assignment
nnoremap d= df=x
nnoremap c= df=xi

" Text object for the visible screen
onoremap a+ :<c-u>normal! HVL<cr>
xnoremap a+ :<c-u>normal! HVL<cr>

" Focus marked text by highlighting everything else as a comment
xnoremap <silent> <cr> :<c-u>call <SID>Focus()<cr>
nnoremap <silent> <cr> :call <SID>Unfocus()<cr>

function! s:Focus()
  let start = line("'<")
  let end   = line("'>")

  call matchadd('Comment', '.*\%<'.start.'l')
  call matchadd('Comment', '.*\%>'.end.'l')
  syntax sync fromstart
  redraw
endfunction

function! s:Unfocus()
  call clearmatches()
endfunction

" Source:
" https://stackoverflow.com/questions/44108563/how-to-delete-or-yank-inside-slashes-and-asterisks
"
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '-', '#' ]
  execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
  execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
  execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
  execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor

" Yank current directory path
nnoremap gy :call <SID>YankDir()<cr>
function! s:YankDir()
  let current_dir = getcwd()
  call setreg(v:register, current_dir)
  echomsg 'Yanked "'.current_dir.'" to clipboard ("'.v:register.')'
endfunction

" Easy way to append in normal mode
nnoremap <silent> z, :call put_at_end#Mapping(',')<cr>
nnoremap <silent> z; :call put_at_end#Mapping(';')<cr>
nnoremap <silent> z) :call put_at_end#Mapping('),')<cr>

" Quickly record a .-appliable macro using M
nnoremap M :call quickmacro#Record()<cr>
