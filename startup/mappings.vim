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
nnoremap sj :SplitjoinSplit<CR>
nnoremap sk :SplitjoinJoin<CR>
" Execute normal vim join if in visual mode
xnoremap sk J

" Moving code sideways
nnoremap s< :SidewaysLeft<CR>
nnoremap s> :SidewaysRight<CR>

" Sideways argument text object
omap aa <Plug>SidewaysArgumentTextobjA
xmap aa <Plug>SidewaysArgumentTextobjA
omap ia <Plug>SidewaysArgumentTextobjI
xmap ia <Plug>SidewaysArgumentTextobjI

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
" Relies on surround.vim
nnoremap <silent> dsf :call <SID>DeleteSurroundingFunctionCall()<cr>
function! s:DeleteSurroundingFunctionCall()
  let [success, opening_bracket] = s:FindFunctionCallStart('b')
  if !success
    return
  endif

  exe 'normal! dt'.opening_bracket
  exe 'normal ds'.opening_bracket
  silent! call repeat#set('dsf')
endfunction

" Operate on a function call
onoremap af :<c-u>call <SID>FunctionCallTextObject('a')<cr>
xnoremap af :<c-u>call <SID>FunctionCallTextObject('a')<cr>
onoremap if :<c-u>call <SID>FunctionCallTextObject('i')<cr>
xnoremap if :<c-u>call <SID>FunctionCallTextObject('i')<cr>
function! s:FunctionCallTextObject(mode)
  let [success, opening_bracket] = s:FindFunctionCallStart('')
  if !success
    return
  endif

  if a:mode == 'i'
    exe 'normal! f'.opening_bracket.'vi'.opening_bracket
  else " a:mode == 'a'
    exe 'normal vf'.opening_bracket.'%'
  endif
endfunction

function! s:FindFunctionCallStart(flags)
  let original_iskeyword = &iskeyword

  try
    set iskeyword+=?,!

    if search('\k\+\zs[([]', a:flags, line('.')) <= 0
      return [0, '']
    endif

    " what's the opening bracket?
    let opener = getline('.')[col('.') - 1]

    " go back one word to get to the beginning of the function call
    normal! b

    " now we're on the function's name, see if we should move back some more
    let prefix = strpart(getline('.'), 0, col('.') - 1)
    while prefix =~ '\k\(\.\|::\|:\|#\)$'
      if search('\k\+', 'b', line('.')) <= 0
        break
      endif
      let prefix = strpart(getline('.'), 0, col('.') - 1)
    endwhile

    return [1, opener]
  finally
    let &iskeyword = original_iskeyword
  endtry
endfunction

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

  exe "Ack '\\b".a:word."\\b'"

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
nmap g/ :vimgrep /<C-R>//j %<CR>\|:cw<CR>

" Bufsurf
nnoremap <c-w>< :BufSurfBack<CR>
nnoremap <c-w>> :BufSurfForward<CR>

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
    let b:dh_closing_pattern = '.'
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

  if end_lineno - start_lineno > 1
    exe (start_lineno + 1).','.(end_lineno - 1).'<'

    if indent(end_lineno) == indent(start_lineno) &&
          \ getline(end_lineno) =~ b:dh_closing_pattern
      " then it's a block-closer, delete it
      exe end_lineno.'delete _'
    endif
  endif

  exe start_lineno.'delete'
  echo
endfunction

" Change between `method arg1, arg2` and `method(arg1, arg2)`
nnoremap g( :Repeatable call <SID>ToggleBrackets()<cr>
nnoremap g) :Repeatable call <SID>ToggleBrackets()<cr>
function! s:ToggleBrackets()
  let arguments = sideways#Parse()
  if empty(arguments)
    return
  endif

  let saved_view = winsaveview()

  let start_lineno = arguments[0][0]
  let start_line   = getline(start_lineno)
  let end_lineno   = arguments[-1][0]
  let end_line     = getline(end_lineno)

  let start_col       = arguments[0][1]
  let start_col_index = start_col - 1
  let end_col         = arguments[-1][2]
  let end_col_index   = end_col - 1

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

  call winrestview(saved_view)
endfunction

" Quickly make a macro and use it with "."
let s:simple_macro_active = 0
nnoremap M :call <SID>SimpleMacro()<cr>
function! s:SimpleMacro()
  if s:simple_macro_active == 0

    call feedkeys('qm', 'n')
    let s:simple_macro_active = 1

  elseif s:simple_macro_active == 1

    normal! q
    " remove trailing M
    let @m = @m[0:-2]
    call repeat#set(":\<c-u>call repeat#wrap('@m', 1)\<cr>", 1)
    let s:simple_macro_active = 0

  endif
endfunction

" Delete left-hand side of assignment
nnoremap d= df=x

" Text object for the visible screen
onoremap a+ :<c-u>normal! HVL<cr>
xnoremap a+ :<c-u>normal! HVL<cr>

" Focus marked text by highlighting everything else as a comment
xnoremap <silent> <cr> :<c-u>call <SID>Focus()<cr>
nnoremap <silent> <cr> :call <SID>Unfocus()<cr>

function! s:Focus()
  let start = line("'<")
  let end   = line("'>")

  call matchadd('Comment', '\%^\_.*\%<'.start.'l')
  call matchadd('Comment', '\%>'.end.'l\_.*\%$')
  redraw
  syntax sync fromstart
endfunction

function! s:Unfocus()
  call clearmatches()
endfunction

" Easier :Modsearch
nnoremap _s :Modsearch<space>
