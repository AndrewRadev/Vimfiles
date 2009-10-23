" clipbrd.vim -- Clipboard and other register content editor.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 01-Jun-2006 @ 17:57
" Created: 26-May-2004
" Requires: Vim-7.0, genutils.vim(2.0)
" Version: 2.0.1
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=1014
" Usage:
"   - Execute the default map (\cb or <Leader>cb) or :ClipBrd command to view
"     the default register ("*", the clipboard register). You can also specify
"     the register name as an argument to the :ClipBrd command.
"   - The register name is remembered (until you change it again by explicitly
"     specifying it) so that you don't have to specify it everytime you run
"     :ClipBrd command.
"   - The "[Clip Board]" buffer is like a regular Vim file buffer, as you can
"     write (:w, :w!, :wq, :wq!), reload (:e, :e!) and quit (:q, :q!) the
"     buffer using the built-in Vim commands. Writing without the bang will
"     make the plugin prompt you for confirmation and where available, you can
"     click "Cancel" to prevent the buffer from quitting.
"   - To refresh contents from the register, use :e or :e! command, or just
"     close and reopen the buffer. To quit without saving, just use the :q!
"     command.
"   - <C-G> while in the [Clip Board] buffer shows the register name.
"   - Even other buffer commands and settings work as expected, e.g., you can
"     :hide the buffer if you can't decide to save or quit, and the contents
"     should remain the same when you come back, unless a different register
"     is explicitly specified while opening the clipboard. Setting 'bufhidden'
"     to "hide" or 'hidden' also should do the same.
" Installation:
"   - Place the file in your plugin directory.
"   - Also install the latest genutils.vim.
"   - If you don't like the default map (\cb), change it by placing the
"     following in your vimrc (change <Your Map> appropriately):
"       nmap <unique> <silent> <Your Map> <Plug>ClipBrdOpen
"   - If you want to change the default register from "*" to something else,
"     put the following in your vimrc:
"       let g:clipbrdDefaultReg = '+' 
"     The default register is significant only the first time you invoke the
"     ClipBrd without specifying any register.  
"   - You can optionally create a program shortcut with the following as the
"     command:
"
"       gvim +ClipBrd +only
"
"     This allows you to use the shortcut to quickly view and edit the
"     system clipboard. I find it extremely useful. Place the shortcut in a
"     quick reach (like the windows taskbar) and you will have a powerful
"     clipboard editor handy all the time.
" TODO:

if exists('loaded_clipbrd')
  finish
endif
if v:version < 700
  echomsg 'clipbrd: You need at least Vim 7.0'
  finish
endif

if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 200
  echomsg 'clipbrd: You need a newer version of genutils.vim plugin'
  finish
endif
let loaded_clipbrd=1

if !exists('s:myBufNum')
let s:myBufNum = -1
let s:myDir = ''
if exists('g:clipbrdDefaultReg')
  let s:curReg = g:clipbrdDefaultReg
else
  let s:curReg = '*'
endif
let s:title = '[Clip Board]'
endif

command! -nargs=? ClipBrd :call <SID>ViewRegister(<f-args>)

if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_clipbrd_maps") || ! no_clipbrd_maps)
  nnoremap <script> <Plug>ClipBrdOpen :ClipBrd<CR>

  if !hasmapto('<Plug>ClipBrdOpen')
    nmap <unique> <silent> <Leader>cb <Plug>ClipBrdOpen
  endi
endif

function! s:ViewRegister(...)
  let forceRefresh = 0
  if (a:0 > 0 && a:1 != s:curReg)
    let s:curReg = (a:0 > 0 ? a:1 : s:curReg)
    let forceRefresh = 1
  endif

  if s:myBufNum == -1
    " Temporarily modify isfname to avoid treating the name as a pattern.
    let _isf = &isfname
    try
      set isfname-=\
      set isfname-=[
      if exists('+shellslash')
        exec "sp \\\\". escape(s:title, ' ')
      else
        exec "sp \\". escape(s:title, ' ')
      endif
      exec "normal i\<C-G>u\<Esc>"
      let s:myBufNum = bufnr('%')
      let s:myDir = getcwd()
    finally
      let &isfname = _isf
    endtry
  else
    let buffer_win = bufwinnr(s:myBufNum)
    if buffer_win == -1
      exec 'sb '. s:myBufNum
      if a:0 == 0
        return | " BufReadCmd must have done the trick.
      endif
    elseif buffer_win != winnr()
      exec buffer_win . 'wincmd w'
    endif
    " Preserve the buffername, in case the user changed the directory. This is
    "   a hack to get the same functionality as buftype=nofile itself, without
    "   needing to set it (since we want 'modified' flag to be working).
    if s:myDir !=# getcwd()
      try
        exec 'lcd' s:myDir
        setl buftype=nofile
        lcd -
        setl buftype=
      catch
        " Ignore.
      endtry
    endif
  endif
  call s:SetupBuf(s:curReg)

  if forceRefresh || (line('$') == 1 && getline(1) =~ '^$')
    call genutils#OptClearBuffer()
    let v:errmsg = ''
    silent! exec '$put '.s:curReg
    if v:errmsg != ''
      echohl ErrorMsg | echo v:errmsg | echohl NONE
      return
    endif
    silent 1delete _
    setlocal nomodified
  endif
endfunction

function! s:UpdateRegister(confirmed, cancellable)
  if a:confirmed || v:cmdbang
    let response = 1
  else
    let response = confirm('Do you want to update register: "'.s:curReg.
          \ '"? ', "&Yes\n&No".(a:cancellable?"\n&Cancel":''), 1, 'Question')
  endif
  if response == 1
    silent exec '1,$yank' s:curReg
  endif
  if response != 3 " If not cancelled.
    setl nomodified
  else
    setl modified
  endif
endfunction

function! s:SetupBuf(regName)
  call genutils#SetupScratchBuffer()
  " We are not setting 'buftype' as this will make BufWriteCmd unusable.
  setlocal buftype=
  " We are not setting 'bufhidden' because that will allow us to :hide it,
  "   without disturbing the changes.
  setlocal bufhidden=

  " Set some options suitable for pure text editing.
  setlocal tabstop=8
  setlocal softtabstop=0
  setlocal shiftwidth=8
  setlocal noexpandtab
  setlocal autoindent
  setlocal formatoptions=tcqnl
  setlocal comments=:#,fb:-
  setlocal wrapmargin=0
  setlocal textwidth=80
  let b:undo_ftplugin = 'setl ts< sts< sw< et< ai< fo< com< wm< tw<'

  nnoremap <buffer> <silent> <C-G> :call <SID>ShowSummary()<CR>

  let auTitle = escape(s:title, '\[*^$. ')
  aug ClipBrd
    au!
    exec 'au BufWriteCmd ' . auTitle .' :call <SID>UpdateRegister(0, 1)'
    exec 'au BufReadCmd ' . auTitle .' :call <SID>ViewRegister()'
  aug END
endfunction

function! s:ShowSummary()
  let summary = genutils#GetVimCmdOutput('file')
  let summary = substitute(summary, '" \(\[New file]\)\=',
        \ '" [Register '.s:curReg.']', '')
  echo summary
endfunction

" vim6:fdm=marker et sw=2
