" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/Decho.vim	[[[1
592
" Decho.vim:   Debugging support for VimL
" Maintainer:  Charles E. Campbell, Jr. PhD <cec@NgrOyphSon.gPsfAc.nMasa.gov>
" Date:        Oct 23, 2008
" Version:     20
"
" Usage: {{{1
"   Decho "a string"
"   call Decho("another string")
"   let g:decho_bufname = "ANewDBGBufName"
"   let g:decho_bufenter= 1    " tells Decho to ignore BufEnter, WinEnter,
"                              " WinLeave events while Decho is working
"   call Decho("one","thing","after","another")
"   DechoOn     : removes any first-column '"' from lines containing Decho
"   DechoOff    : inserts a '"' into the first-column in lines containing Decho
"   DechoMsgOn  : use echomsg instead of DBG buffer
"   DechoMsgOff : turn debugging off
"   DechoRemOn  : turn remote Decho messaging on
"   DechoRemOff : turn remote Decho messaging off
"   DechoVarOn [varname] : use variable to write debugging messages to
"   DechoVarOff : turn debugging off
"   DechoTabOn  : turn debugging on (uses a separate tab)
"   DechoTabOff : turn debugging off
"
" GetLatestVimScripts: 120 1 :AutoInstall: Decho.vim
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_Decho") || &cp
 finish
endif
let g:loaded_Decho = "v20"
let s:keepcpo      = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Default Values For Variables: {{{1
if !exists("g:decho_bufname")
 let g:decho_bufname= "DBG"
endif
if !exists("s:decho_depth")
 let s:decho_depth  = 0
endif
if !exists("g:decho_winheight")
 let g:decho_winheight= 5
endif
if !exists("g:decho_bufenter")
 let g:decho_bufenter= 0
endif
if !exists("g:dechomode") || !exists("s:DECHOWIN")
 let s:DECHOWIN = 1
 let s:DECHOMSG = 2
 let s:DECHOVAR = 3
 let s:DECHOREM = 4
 let s:DECHOTAB = 5
 let g:dechomode= s:DECHOWIN
endif
if !exists("g:dechovarname")
 let g:dechovarname = "g:dechovar"
endif

" ---------------------------------------------------------------------
"  User Interface: {{{1
com! -nargs=+ -complete=expression Decho	call Decho(<args>)
com! -nargs=+ -complete=expression Dredir	call Dredir(<args>)
com! -nargs=0 -range=% DechoOn				call DechoOn(<line1>,<line2>)
com! -nargs=0 -range=% DechoOff				call DechoOff(<line1>,<line2>)
com! -nargs=0 Dhide    						call s:Dhide(1)
com! -nargs=0 Dshow    						call s:Dhide(0)
com! -nargs=0 DechoMsgOn					call s:DechoMsg(1,expand("<sfile>"))
com! -nargs=0 DechoMsgOff					call s:DechoMsg(0)
if has("clientserver") && executable("gvim")
 com! -nargs=0 DechoRemOn					call s:DechoRemote(1,expand("<sfile>"))
 com! -nargs=0 DechoRemOff					call s:DechoRemote(0)
endif
com! -nargs=? DechoSep						call DechoSep(<args>)
com! -nargs=? Dsep						    call DechoSep(<args>)
com! -nargs=? DechoVarOn					call s:DechoVarOn(expand("<sfile>"),<args>)
com! -nargs=0 DechoVarOff					call s:DechoVarOff()
if v:version >= 700
 com! -nargs=? DechoTabOn                   set lz|call s:DechoTab(1,expand("<sfile>"))|set nolz
 com! -nargs=? DechoTabOff                  set lz|call s:DechoTab(0)|set nolz
endif
com! -nargs=0 DechoPause					call DechoPause()
au Filetype Decho nmap <silent> <buffer> <F1> :setlocal noro ma<cr>

" ---------------------------------------------------------------------
" Decho: the primary debugging function: splits the screen as necessary and {{{1
"        writes messages to a small window (g:decho_winheight lines)
"        on the bottom of the screen
fun! Decho(...)
 
  " make sure that SaveWinPosn() and RestoreWinPosn() are available
  if !exists("g:loaded_cecutil")
   runtime plugin/cecutil.vim
   if !exists("g:loaded_cecutil") && exists("g:loaded_AsNeeded")
   	AN SWP
   endif
   if !exists("g:loaded_cecutil")
   	echoerr "***Decho*** need to load <cecutil.vim>"
	return
   endif
  endif

  " open DBG window (if dechomode is dechowin)
  if g:dechomode == s:DECHOWIN
   let swp   = SaveWinPosn(0)
   let curbuf= bufnr("%")
   if g:decho_bufenter
    let eikeep= &ei
	let eakeep= &ea
	set ei=BufEnter,WinEnter,WinLeave,ShellCmdPost,FocusGained noea
   endif
 
   " As needed, create/switch-to the DBG buffer
   if !bufexists(g:decho_bufname) && bufnr("*/".g:decho_bufname."$") == -1
    " if requested DBG-buffer doesn't exist, create a new one
    " at the bottom of the screen.
	exe "keepjumps silent! bot ".g:decho_winheight."new ".fnameescape(g:decho_bufname)
    setlocal noswf
	keepjumps silent! %d
 
   elseif bufwinnr(g:decho_bufname) > 0
    " if requested DBG-buffer exists in a window,
    " go to that window (by window number)
    exe "keepjumps ".bufwinnr(g:decho_bufname)."wincmd W"
    exe "res ".g:decho_winheight
 
   else
    " user must have closed the DBG-buffer window.
    " create a new one at the bottom of the screen.
    exe "keepjumps silent bot ".g:decho_winheight."new"
    setlocal noswf
    exe "keepjumps b ".bufnr(g:decho_bufname)
   endif
 
   set ft=Decho
   setlocal noswapfile noro nobl fo=n2croql
 
   "  make sure DBG window is on the bottom
   wincmd J
  endif

  " Build Message
  let i  = 1
  let msg= ""
  while i <= a:0
   try
    exe "let msg=msg.a:".i
   catch /^Vim\%((\a\+)\)\=:E730/
       " looks like a:i is a list
    exe "let msg=msg.string(a:".i.")"
   endtry
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile

  " Initialize message
  let smsg   = ""
  let idepth = 0
  while idepth < s:decho_depth
   let smsg   = "|".smsg
   let idepth = idepth + 1
  endwhile

  " Handle special characters (\t \r \n)
  " and append msg to smsg
  let i    = 1
  while msg != ""
   let chr  = strpart(msg,0,1)
   let msg  = strpart(msg,1)
   if char2nr(chr) < 32
   	let smsg = smsg.'^'.nr2char(64+char2nr(chr))
   else
    let smsg = smsg.chr
   endif
  endwhile

"  echomsg "g:dechomode=".g:dechomode
  if g:dechomode == s:DECHOMSG
   " display message with echomsg
   exe "echomsg '".substitute(smsg,"'","'.\"'\".'","ge")."'"

  elseif g:dechomode == s:DECHOVAR
   " "display" message by appending to variable named by g:dechovarname
   let smsg= substitute(smsg,"'","''","ge")
   if exists(g:dechovarname)
    exe "let ".g:dechovarname."= ".g:dechovarname.".'\n".smsg."'"
   else
    exe "let ".g:dechovarname."= '".smsg."'"
   endif

  elseif g:dechomode == s:DECHOREM
   " display message by appending it to remote DECHOREMOTE vim server
   let smsg= substitute(smsg,"\<esc>","\<c-v>\<esc>","ge")
   try
    call remote_send("DECHOREMOTE",':set ma fo-=at'."\<cr>".'Go'.smsg."\<esc>".':set noma nomod'."\<cr>")
   catch /^Vim\%((\a\+)\)\=:E241/
       let g:dechomode= s:DECHOWIN
   endtry

  elseif g:dechomode == s:DECHOTAB
   " display message by appending it to the debugging tab window
   let eikeep= &ei
   set ei=all
   let g:dechotabcur = tabpagenr()
   exe "silent! tabn ".g:dechotabnr
   if expand("%") != "Decho Tab"
	" looks like a new tab has been inserted -- look for the "Decho Tab" tab
	let g:dechotabnr= 1
	silent! tabn 1
	while expand("%") != "Decho Tab"
	 let g:dechotabnr= g:dechotabnr + 1
	 if g:dechotabnr > tabpagenr("$")
	  " re-enable the "Decho Tab" tab -- looks like it was closed!
	  call s:DechoTab(1)
	  break
	 endif
     exe "tabn".g:dechotabnr
    endwhile
   endif
   " append message to "Decho Tab" tab
   setlocal ma noro
   call setline(line("$")+1,smsg)
   setlocal noma nomod
   " restore tab# to original user tab
   exe "tabn ".g:dechotabcur
   let &ei= eikeep

  else
   " Write Message to DBG buffer
   setlocal ma
   keepjumps $
   keepjumps let res= append("$",smsg)
   setlocal nomod
 
   " Put cursor at bottom of DBG window, then return to original window
   exe "res ".g:decho_winheight
   keepjumps norm! G
   if exists("g:decho_hide") && g:decho_hide > 0
    setlocal hidden
    q
   endif
   keepjumps wincmd p
   if exists("swp")
    call RestoreWinPosn(swp)
   endif
 
   if g:decho_bufenter
    let &ei= eikeep
	let &ea= eakeep
   endif
  endif
endfun

" ---------------------------------------------------------------------
"  Dfunc: just like Decho, except that it also bumps up the depth {{{1
"         It also appends a "{" to facilitate use of %
"         Usage:  call Dfunc("functionname([opt arglist])")
fun! Dfunc(...)
  " Build Message
  let i  = 1
  let msg= ""
  while i <= a:0
   exe "let msg=msg.a:".i
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile
  let msg= msg." {"
  call Decho(msg)
  let s:decho_depth= s:decho_depth + 1
  let s:Dfunclist_{s:decho_depth}= substitute(msg,'[( \t].*$','','')
endfun

" ---------------------------------------------------------------------
"  Dret: just like Decho, except that it also bumps down the depth {{{1
"        It also appends a "}" to facilitate use of %
"         Usage:  call Dret("functionname [optional return] [: optional extra info]")
fun! Dret(...)
  " Build Message
  let i  = 1
  let msg= ""
  while i <= a:0
   exe "let msg=msg.a:".i
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile
  let msg= msg." }"
  call Decho("return ".msg)
  if s:decho_depth > 0
   let retfunc= substitute(msg,'\s.*$','','e')
   if  retfunc != s:Dfunclist_{s:decho_depth}
   	echoerr "Dret: appears to be called by<".s:Dfunclist_{s:decho_depth}."> but returning from<".retfunc.">"
   endif
   unlet s:Dfunclist_{s:decho_depth}
   let s:decho_depth= s:decho_depth - 1
  endif
endfun

" ---------------------------------------------------------------------
" DechoOn: {{{1
fun! DechoOn(line1,line2)
  let ickeep= &ic
  set noic
  let swp    = SaveWinPosn(0)
  let dbgpat = '\<D\%(echo\|func\|redir\|ret\|echo\%(Msg\|Rem\|Tab\|Var\)O\%(n\|ff\)\)\>'
  if search(dbgpat,'cnw') == 0
   echoerr "this file<".expand("%")."> does not contain any Decho/Dfunc/Dret commands or function calls!"
  else
   exe "keepjumps ".a:line1.",".a:line2.'g/'.dbgpat.'/s/^"\+//'
  endif
  call RestoreWinPosn(swp)
  let &ic= ickeep
endfun

" ---------------------------------------------------------------------
" DechoOff: {{{1
fun! DechoOff(line1,line2)
  let ickeep= &ic
  set noic
  let swp=SaveWinPosn(0)
  let swp= SaveWinPosn(0)
  exe "keepjumps ".a:line1.",".a:line2.'g/\<D\%(echo\|func\|redir\|ret\|echo\%(Msg\|Rem\|Tab\|Var\)O\%(n\|ff\)\)\>/s/^[^"]/"&/'
  call RestoreWinPosn(swp)
  let &ic= ickeep
endfun

" ---------------------------------------------------------------------
" DechoDepth: allow user to force depth value {{{1
fun! DechoDepth(depth)
  let s:decho_depth= a:depth
endfun

" ---------------------------------------------------------------------
" s:DechoMsg: {{{2
fun! s:DechoMsg(onoff,...)
"  call Dfunc("s:DechoMsg(onoff=".a:onoff.") a:0=".a:0)
  if a:onoff
   let g:dechomode = s:DECHOMSG
   let g:dechofile = (a:0 > 0)? a:1 : ""
  else
   let g:dechomode= s:DECHOWIN
  endif
"  call Dret("s:DechoMsg")
endfun

" ---------------------------------------------------------------------
" Dhide: (un)hide DBG buffer {{{1
fun! <SID>Dhide(hide)

  if !bufexists(g:decho_bufname) && bufnr("*/".g:decho_bufname."$") == -1
   " DBG-buffer doesn't exist, simply set g:decho_hide
   let g:decho_hide= a:hide

  elseif bufwinnr(g:decho_bufname) > 0
   " DBG-buffer exists in a window, so its not currently hidden
   if a:hide == 0
   	" already visible!
    let g:decho_hide= a:hide
   else
   	" need to hide window.  Goto window and make hidden
	let curwin = winnr()
	let dbgwin = bufwinnr(g:decho_bufname)
    exe bufwinnr(g:decho_bufname)."wincmd W"
	setlocal hidden
	q
	if dbgwin != curwin
	 " return to previous window
     exe curwin."wincmd W"
	endif
   endif

  else
   " The DBG-buffer window is currently hidden.
   if a:hide == 0
	let curwin= winnr()
    exe "silent bot ".g:decho_winheight."new"
    setlocal bh=wipe
    exe "b ".bufnr(g:decho_bufname)
    exe curwin."wincmd W"
   else
   	let g:decho_hide= a:hide
   endif
  endif
  let g:decho_hide= a:hide
endfun

" ---------------------------------------------------------------------
" Dredir: this function performs a debugging redir by temporarily using {{{1
"         register a in a redir @a of the given command.  Register a's
"         original contents are restored.
"   Usage:  Dredir(["string","string",...,]"cmd")
fun! Dredir(...)
  if a:0 <= 0
   return
  endif
  let icmd = 1
  while icmd < a:0
   call Decho(a:{icmd})
   let icmd= icmd + 1
  endwhile
  let cmd= a:{icmd}

  " save register a, initialize
  let keep_rega = @a
  let v:errmsg  = ''

  " do the redir of the command to the register a
  try
   redir @a
    exe "keepjumps silent ".cmd
  catch /.*/
   let v:errmsg= substitute(v:exception,'^[^:]\+:','','e')
  finally
   redir END
   if v:errmsg == ''
   	let output= @a
   else
   	let output= v:errmsg
   endif
   let @a= keep_rega
  endtry

  " process output via Decho()
  while output != ""
   if output =~ "\n"
   	let redirline = substitute(output,'\n.*$','','e')
   	let output    = substitute(output,'^.\{-}\n\(.*$\)$','\1','e')
   else
   	let redirline = output
   	let output    = ""
   endif
   call Decho("redir<".cmd.">: ".redirline)
  endwhile
endfun

" ---------------------------------------------------------------------
" DechoSep: puts a separator with counter into debugging output {{{2
fun! DechoSep(...)
"  call Dfunc("DechoSep() a:0=".a:0)
  if !exists("s:dechosepcnt")
   let s:dechosepcnt= 1
  else
   let s:dechosepcnt= s:dechosepcnt + 1
  endif
  let eikeep= &ei
  set ei=all
  call Decho("--sep".s:dechosepcnt."--".((a:0 > 0)? " ".a:1 : ""))
  let &ei= eikeep
"  call Dret("DechoSep")
endfun

" ---------------------------------------------------------------------
" DechoPause: puts a pause-until-<cr> into operation; will place a {{{2
"             separator into the debug output for reporting
fun! DechoPause()
"  call Dfunc("DechoPause()")
  redraw!
  call DechoSep("(pause)")
  call inputsave()
  call input("Press <cr> to continue")
  call inputrestore()
"  call Dret("DechoPause")
endfun

 " ---------------------------------------------------------------------
 " DechoRemote: supports sending debugging to a remote vim {{{1
if has("clientserver") && executable("gvim")
 fun! s:DechoRemote(mode,...)
   if a:mode == 0
    " turn remote debugging off
    if g:dechomode == s:DECHOREM
    	let g:dechomode= s:DECHOWIN
    endif
 
   elseif a:mode == 1
    " turn remote debugging on
    if g:dechomode != s:DECHOREM
 	 let g:dechomode= s:DECHOREM
    endif
	let g:dechofile= (a:0 > 0)? a:1 : ""
    if serverlist() !~ '\<DECHOREMOTE\>'
 "   " start up remote Decho server
 "   call Decho("start up DECHOREMOTE server")
     if has("win32") && executable("start")
      call system("start gvim --servername DECHOREMOTE")
	 else
      call system("gvim --servername DECHOREMOTE")
	 endif
     while 1
      try
 	   call remote_send("DECHOREMOTE",':silent set ft=Decho fo-=at'."\<cr>")
       call remote_send("DECHOREMOTE",':file [Decho\ Remote\ Server]'."\<cr>")
 	   call remote_send("DECHOREMOTE",":put ='-----------------------------'\<cr>")
 	   call remote_send("DECHOREMOTE",":put ='Remote Decho Debugging Window'\<cr>")
 	   call remote_send("DECHOREMOTE",":put ='-----------------------------'\<cr>")
 	   call remote_send("DECHOREMOTE","1GddG")
	   call remote_send("DECHOREMOTE",':silent set noswf noma nomod nobl nonu ch=1 fo=n2croql nosi noai'."\<cr>")
 	   call remote_send("DECHOREMOTE",':'."\<cr>")
 	   call remote_send("DECHOREMOTE",':silent set ft=Decho'."\<cr>")
 	   call remote_send("DECHOREMOTE",':silent syn on'."\<cr>")
 	   break
      catch /^Vim\%((\a\+)\)\=:E241/
 	   sleep 200m
      endtry
     endwhile
    endif
 
   else
    echohl Warning | echomsg "DechoRemote(".a:mode.") not supported" | echohl None
   endif
 
 endfun
endif

" ---------------------------------------------------------------------
"  DechoVarOn: turu debugging-to-a-variable on.  The variable is given {{{1
"  by the user;   DechoVarOn [varname]
fun! s:DechoVarOn(...)
  let g:dechomode= s:DECHOVAR
  
  if a:0 > 0
   let g:dechofile= a:1
   if a:2 =~ '^g:'
    exe "let ".a:2.'= ""'
   else
    exe "let g:".a:2.'= ""'
   endif
  else
   let g:dechovarname= "g:dechovar"
  endif
endfun

" ---------------------------------------------------------------------
" DechoVarOff: {{{1
fun! s:DechoVarOff()
  if exists("g:dechovarname")
   if exists(g:dechovarname)
    exe "unlet ".g:dechovarname
   endif
  endif
  let g:dechomode= s:DECHOWIN
endfun

 " --------------------------------------------------------------------
 " DechoTab: {{{1
if v:version >= 700
 fun! s:DechoTab(mode,...)
 "  call Dfunc("DechoTab(mode=".a:mode.") a:0=".a:0)
 
   if a:mode
    let g:dechomode = s:DECHOTAB
	let g:dechofile = (a:0 > 0)? a:1 : ""
    let dechotabcur = tabpagenr()
    if !exists("g:dechotabnr")
	 let eikeep= &ei
	 set ei=all
	 tabnew
	 file Decho\ Tab
	 setlocal ma
	 put ='---------'
	 put ='Decho Tab '.g:dechofile
	 put ='---------'
	 norm! 1GddG
	 let g:dechotabnr = tabpagenr()
	 let &ei          = ""
	 set ft=Decho
	 set ei=all
	 setlocal noma nomod nobl noswf ch=1 fo=n2croql
	 exe "tabn ".dechotabcur
	 let &ei= eikeep
	endif
   else
    let g:dechomode= s:DECHOWIN
   endif
 
 "  call Dret("DechoTab")
 endfun
endif

" ---------------------------------------------------------------------
"  End Plugin: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
"  vim: ts=4 fdm=marker
plugin/cecutil.vim	[[[1
508
" cecutil.vim : save/restore window position
"               save/restore mark position
"               save/restore selected user maps
"  Author:	Charles E. Campbell, Jr.
"  Version:	18b	ASTRO-ONLY
"  Date:	Aug 27, 2008
"
"  Saving Restoring Destroying Marks: {{{1
"       call SaveMark(markname)       let savemark= SaveMark(markname)
"       call RestoreMark(markname)    call RestoreMark(savemark)
"       call DestroyMark(markname)
"       commands: SM RM DM
"
"  Saving Restoring Destroying Window Position: {{{1
"       call SaveWinPosn()        let winposn= SaveWinPosn()
"       call RestoreWinPosn()     call RestoreWinPosn(winposn)
"		\swp : save current window/buffer's position
"		\rwp : restore current window/buffer's previous position
"       commands: SWP RWP
"
"  Saving And Restoring User Maps: {{{1
"       call SaveUserMaps(mapmode,maplead,mapchx,suffix)
"       call RestoreUserMaps(suffix)
"
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim
"
" You believe that God is one. You do well. The demons also {{{1
" believe, and shudder. But do you want to know, vain man, that
" faith apart from works is dead?  (James 2:19,20 WEB)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_cecutil")
 finish
endif
let g:loaded_cecutil = "v18b"
let s:keepcpo        = &cpo
set cpo&vim
"DechoTabOn

" =======================
"  Public Interface: {{{1
" =======================

" ---------------------------------------------------------------------
"  Map Interface: {{{2
if !hasmapto('<Plug>SaveWinPosn')
 map <unique> <Leader>swp <Plug>SaveWinPosn
endif
if !hasmapto('<Plug>RestoreWinPosn')
 map <unique> <Leader>rwp <Plug>RestoreWinPosn
endif
nmap <silent> <Plug>SaveWinPosn		:call SaveWinPosn()<CR>
nmap <silent> <Plug>RestoreWinPosn	:call RestoreWinPosn()<CR>

" ---------------------------------------------------------------------
" Command Interface: {{{2
com! -bar -nargs=0 SWP	call SaveWinPosn()
com! -bar -nargs=0 RWP	call RestoreWinPosn()
com! -bar -nargs=1 SM	call SaveMark(<q-args>)
com! -bar -nargs=1 RM	call RestoreMark(<q-args>)
com! -bar -nargs=1 DM	call DestroyMark(<q-args>)

if v:version < 630
 let s:modifier= "sil "
else
 let s:modifier= "sil keepj "
endif

" ===============
" Functions: {{{1
" ===============

" ---------------------------------------------------------------------
" SaveWinPosn: {{{2
"    let winposn= SaveWinPosn()  will save window position in winposn variable
"    call SaveWinPosn()          will save window position in b:cecutil_winposn{b:cecutil_iwinposn}
"    let winposn= SaveWinPosn(0) will *only* save window position in winposn variable (no stacking done)
fun! SaveWinPosn(...)
"  call Dfunc("SaveWinPosn() a:0=".a:0)
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("SaveWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &l:so
  let siso_keep = &l:siso
  let ss_keep   = &l:ss
  setlocal so=0 siso=0 ss=0

  let swline    = line(".")
  let swcol     = col(".")
  let swwline   = winline() - 1
  let swwcol    = virtcol(".") - wincol()
  let savedposn = "call GoWinbufnr(".winbufnr(0).")|silent ".swline
  let savedposn = savedposn."|".s:modifier."norm! 0z\<cr>"
  if swwline > 0
   let savedposn= savedposn.":".s:modifier."norm! ".swwline."\<c-y>\<cr>"
  endif
  if swwcol > 0
   let savedposn= savedposn.":".s:modifier."norm! 0".swwcol."zl\<cr>"
  endif
  let savedposn = savedposn.":".s:modifier."call cursor(".swline.",".swcol.")\<cr>"

  " save window position in
  " b:cecutil_winposn_{iwinposn} (stack)
  " only when SaveWinPosn() is used
  if a:0 == 0
   if !exists("b:cecutil_iwinposn")
   	let b:cecutil_iwinposn= 1
   else
   	let b:cecutil_iwinposn= b:cecutil_iwinposn + 1
   endif
"   call Decho("saving posn to SWP stack")
   let b:cecutil_winposn{b:cecutil_iwinposn}= savedposn
  endif

  let &l:so   = so_keep
  let &l:siso = siso_keep
  let &l:ss   = ss_keep

"  if exists("b:cecutil_iwinposn")	 " Decho
"   call Decho("b:cecutil_winpos{".b:cecutil_iwinposn."}[".b:cecutil_winposn{b:cecutil_iwinposn}."]")
"  else                      " Decho
"   call Decho("b:cecutil_iwinposn doesn't exist")
"  endif                     " Decho
"  call Dret("SaveWinPosn [".savedposn."]")
  return savedposn
endfun

" ---------------------------------------------------------------------
" RestoreWinPosn: {{{2
fun! RestoreWinPosn(...)
"  call Dfunc("RestoreWinPosn() a:0=".a:0)
"  call Decho("getline(1)<".getline(1).">")
"  call Decho("line(.)=".line("."))
  if line(".") == 1 && getline(1) == ""
"   call Dfunc("RestoreWinPosn : empty buffer")
   return ""
  endif
  let so_keep   = &l:so
  let siso_keep = &l:siso
  let ss_keep   = &l:ss
  setlocal so=0 siso=0 ss=0

  if a:0 == 0 || a:1 == ""
   " use saved window position in b:cecutil_winposn{b:cecutil_iwinposn} if it exists
   if exists("b:cecutil_iwinposn") && exists("b:cecutil_winposn{b:cecutil_iwinposn}")
"   	call Decho("using stack b:cecutil_winposn{".b:cecutil_iwinposn."}<".b:cecutil_winposn{b:cecutil_iwinposn}.">")
	try
     exe "silent! ".b:cecutil_winposn{b:cecutil_iwinposn}
	catch /^Vim\%((\a\+)\)\=:E749/
	 " ignore empty buffer error messages
	endtry
    " normally drop top-of-stack by one
    " but while new top-of-stack doesn't exist
    " drop top-of-stack index by one again
	if b:cecutil_iwinposn >= 1
	 unlet b:cecutil_winposn{b:cecutil_iwinposn}
	 let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 while b:cecutil_iwinposn >= 1 && !exists("b:cecutil_winposn{b:cecutil_iwinposn}")
	  let b:cecutil_iwinposn= b:cecutil_iwinposn - 1
	 endwhile
	 if b:cecutil_iwinposn < 1
	  unlet b:cecutil_iwinposn
	 endif
	endif
   else
   	echohl WarningMsg
	echomsg "***warning*** need to SaveWinPosn first!"
	echohl None
   endif

  else	 " handle input argument
"   call Decho("using input a:1<".a:1.">")
   " use window position passed to this function
   exe "silent ".a:1
   " remove a:1 pattern from b:cecutil_winposn{b:cecutil_iwinposn} stack
   if exists("b:cecutil_iwinposn")
    let jwinposn= b:cecutil_iwinposn
    while jwinposn >= 1                     " search for a:1 in iwinposn..1
        if exists("b:cecutil_winposn{jwinposn}")    " if it exists
         if a:1 == b:cecutil_winposn{jwinposn}      " and the pattern matches
       unlet b:cecutil_winposn{jwinposn}            " unlet it
       if jwinposn == b:cecutil_iwinposn            " if at top-of-stack
        let b:cecutil_iwinposn= b:cecutil_iwinposn - 1      " drop stacktop by one
       endif
      endif
     endif
     let jwinposn= jwinposn - 1
    endwhile
   endif
  endif

  " Seems to be something odd: vertical motions after RWP
  " cause jump to first column.  The following fixes that.
  " Note: was using wincol()>1, but with signs, a cursor
  " at column 1 yields wincol()==3.  Beeping ensued.
  if virtcol('.') > 1
   silent norm! hl
  elseif virtcol(".") < virtcol("$")
   silent norm! lh
  endif

  let &l:so   = so_keep
  let &l:siso = siso_keep
  let &l:ss   = ss_keep

"  call Dret("RestoreWinPosn")
endfun

" ---------------------------------------------------------------------
" GoWinbufnr: go to window holding given buffer (by number) {{{2
"   Prefers current window; if its buffer number doesn't match,
"   then will try from topleft to bottom right
fun! GoWinbufnr(bufnum)
"  call Dfunc("GoWinbufnr(".a:bufnum.")")
  if winbufnr(0) == a:bufnum
"   call Dret("GoWinbufnr : winbufnr(0)==a:bufnum")
   return
  endif
  winc t
  let first=1
  while winbufnr(0) != a:bufnum && (first || winnr() != 1)
  	winc w
	let first= 0
   endwhile
"  call Dret("GoWinbufnr")
endfun

" ---------------------------------------------------------------------
" SaveMark: sets up a string saving a mark position. {{{2
"           For example, SaveMark("a")
"           Also sets up a global variable, g:savemark_{markname}
fun! SaveMark(markname)
"  call Dfunc("SaveMark(markname<".a:markname.">)")
  let markname= a:markname
  if strpart(markname,0,1) !~ '\a'
   let markname= strpart(markname,1,1)
  endif
"  call Decho("markname=".markname)

  let lzkeep  = &lz
  set lz

  if 1 <= line("'".markname) && line("'".markname) <= line("$")
   let winposn               = SaveWinPosn(0)
   exe s:modifier."norm! `".markname
   let savemark              = SaveWinPosn(0)
   let g:savemark_{markname} = savemark
   let savemark              = markname.savemark
   call RestoreWinPosn(winposn)
  else
   let g:savemark_{markname} = ""
   let savemark              = ""
  endif

  let &lz= lzkeep

"  call Dret("SaveMark : savemark<".savemark.">")
  return savemark
endfun

" ---------------------------------------------------------------------
" RestoreMark: {{{2
"   call RestoreMark("a")  -or- call RestoreMark(savemark)
fun! RestoreMark(markname)
"  call Dfunc("RestoreMark(markname<".a:markname.">)")

  if strlen(a:markname) <= 0
"   call Dret("RestoreMark : no such mark")
   return
  endif
  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname." strlen(a:markname)=".strlen(a:markname))

  let lzkeep  = &lz
  set lz
  let winposn = SaveWinPosn(0)

  if strlen(a:markname) <= 2
   if exists("g:savemark_{markname}") && strlen(g:savemark_{markname}) != 0
	" use global variable g:savemark_{markname}
"	call Decho("use savemark list")
	call RestoreWinPosn(g:savemark_{markname})
	exe "norm! m".markname
   endif
  else
   " markname is a savemark command (string)
"	call Decho("use savemark command")
   let markcmd= strpart(a:markname,1)
   call RestoreWinPosn(markcmd)
   exe "norm! m".markname
  endif

  call RestoreWinPosn(winposn)
  let &lz       = lzkeep

"  call Dret("RestoreMark")
endfun

" ---------------------------------------------------------------------
" DestroyMark: {{{2
"   call DestroyMark("a")  -- destroys mark
fun! DestroyMark(markname)
"  call Dfunc("DestroyMark(markname<".a:markname.">)")

  " save options and set to standard values
  let reportkeep= &report
  let lzkeep    = &lz
  set lz report=10000

  let markname= strpart(a:markname,0,1)
  if markname !~ '\a'
   " handles 'a -> a styles
   let markname= strpart(a:markname,1,1)
  endif
"  call Decho("markname=".markname)

  let curmod  = &mod
  let winposn = SaveWinPosn(0)
  1
  let lineone = getline(".")
  exe "k".markname
  d
  put! =lineone
  let &mod    = curmod
  call RestoreWinPosn(winposn)

  " restore options to user settings
  let &report = reportkeep
  let &lz     = lzkeep

"  call Dret("DestroyMark")
endfun

" ---------------------------------------------------------------------
" QArgSplitter: to avoid \ processing by <f-args>, <q-args> is needed. {{{2
" However, <q-args> doesn't split at all, so this one returns a list
" with splits at all whitespace (only!), plus a leading length-of-list.
" The resulting list:  qarglist[0] corresponds to a:0
"                      qarglist[i] corresponds to a:{i}
fun! QArgSplitter(qarg)
"  call Dfunc("QArgSplitter(qarg<".a:qarg.">)")
  let qarglist    = split(a:qarg)
  let qarglistlen = len(qarglist)
  let qarglist    = insert(qarglist,qarglistlen)
"  call Dret("QArgSplitter ".string(qarglist))
  return qarglist
endfun

" ---------------------------------------------------------------------
" ListWinPosn: {{{2
"fun! ListWinPosn()                                                        " Decho 
"  if !exists("b:cecutil_iwinposn") || b:cecutil_iwinposn == 0             " Decho 
"   call Decho("nothing on SWP stack")                                     " Decho
"  else                                                                    " Decho
"   let jwinposn= b:cecutil_iwinposn                                       " Decho 
"   while jwinposn >= 1                                                    " Decho 
"    if exists("b:cecutil_winposn{jwinposn}")                              " Decho 
"     call Decho("winposn{".jwinposn."}<".b:cecutil_winposn{jwinposn}.">") " Decho 
"    else                                                                  " Decho 
"     call Decho("winposn{".jwinposn."} -- doesn't exist")                 " Decho 
"    endif                                                                 " Decho 
"    let jwinposn= jwinposn - 1                                            " Decho 
"   endwhile                                                               " Decho 
"  endif                                                                   " Decho
"endfun                                                                    " Decho 
"com! -nargs=0 LWP	call ListWinPosn()                                    " Decho 

" ---------------------------------------------------------------------
" SaveUserMaps: this function sets up a script-variable (s:restoremap) {{{2
"          which can be used to restore user maps later with
"          call RestoreUserMaps()
"
"          mapmode - see :help maparg for details (n v o i c l "")
"                    ex. "n" = Normal
"                    The letters "b" and "u" are optional prefixes;
"                    The "u" means that the map will also be unmapped
"                    The "b" means that the map has a <buffer> qualifier
"                    ex. "un"  = Normal + unmapping
"                    ex. "bn"  = Normal + <buffer>
"                    ex. "bun" = Normal + <buffer> + unmapping
"                    ex. "ubn" = Normal + <buffer> + unmapping
"          maplead - see mapchx
"          mapchx  - "<something>" handled as a single map item.
"                    ex. "<left>"
"                  - "string" a string of single letters which are actually
"                    multiple two-letter maps (using the maplead:
"                    maplead . each_character_in_string)
"                    ex. maplead="\" and mapchx="abc" saves user mappings for
"                        \a, \b, and \c
"                    Of course, if maplead is "", then for mapchx="abc",
"                    mappings for a, b, and c are saved.
"                  - :something  handled as a single map item, w/o the ":"
"                    ex.  mapchx= ":abc" will save a mapping for "abc"
"          suffix  - a string unique to your plugin
"                    ex.  suffix= "DrawIt"
fun! SaveUserMaps(mapmode,maplead,mapchx,suffix)
"  call Dfunc("SaveUserMaps(mapmode<".a:mapmode."> maplead<".a:maplead."> mapchx<".a:mapchx."> suffix<".a:suffix.">)")

  if !exists("s:restoremap_{a:suffix}")
   " initialize restoremap_suffix to null string
   let s:restoremap_{a:suffix}= ""
  endif

  " set up dounmap: if 1, then save and unmap  (a:mapmode leads with a "u")
  "                 if 0, save only
  let mapmode  = a:mapmode
  let dounmap  = 0
  let dobuffer = ""
  while mapmode =~ '^[bu]'
   if     mapmode =~ '^u'
    let dounmap= 1
    let mapmode= strpart(a:mapmode,1)
   elseif mapmode =~ '^b'
    let dobuffer= "<buffer> "
    let mapmode= strpart(a:mapmode,1)
   endif
  endwhile
"  call Decho("dounmap=".dounmap."  dobuffer<".dobuffer.">")
 
  " save single map :...something...
  if strpart(a:mapchx,0,1) == ':'
"   call Decho("save single map :...something...")
   let amap= strpart(a:mapchx,1)
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
   endif
   let amap                    = a:maplead.amap
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:silent! ".mapmode."unmap ".dobuffer.amap
   if maparg(amap,mapmode) != ""
    let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|:".mapmode."map ".dobuffer.amap." ".maprhs
   endif
   if dounmap
	exe "silent! ".mapmode."unmap ".dobuffer.amap
   endif
 
  " save single map <something>
  elseif strpart(a:mapchx,0,1) == '<'
"   call Decho("save single map <something>")
   let amap       = a:mapchx
   if amap == "|" || amap == "\<c-v>"
    let amap= "\<c-v>".amap
"	call Decho("amap[[".amap."]]")
   endif
   let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".dobuffer.amap
   if maparg(a:mapchx,mapmode) != ""
    let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".amap." ".dobuffer.maprhs
   endif
   if dounmap
	exe "silent! ".mapmode."unmap ".dobuffer.amap
   endif
 
  " save multiple maps
  else
"   call Decho("save multiple maps")
   let i= 1
   while i <= strlen(a:mapchx)
    let amap= a:maplead.strpart(a:mapchx,i-1,1)
	if amap == "|" || amap == "\<c-v>"
	 let amap= "\<c-v>".amap
	endif
	let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|silent! ".mapmode."unmap ".dobuffer.amap
    if maparg(amap,mapmode) != ""
     let maprhs                  = substitute(maparg(amap,mapmode),'|','<bar>','ge')
	 let s:restoremap_{a:suffix} = s:restoremap_{a:suffix}."|".mapmode."map ".amap." ".dobuffer.maprhs
    endif
	if dounmap
	 exe "silent! ".mapmode."unmap ".dobuffer.amap
	endif
    let i= i + 1
   endwhile
  endif
"  call Dret("SaveUserMaps : restoremap_".a:suffix.": ".s:restoremap_{a:suffix})
endfun

" ---------------------------------------------------------------------
" RestoreUserMaps: {{{2
"   Used to restore user maps saved by SaveUserMaps()
fun! RestoreUserMaps(suffix)
"  call Dfunc("RestoreUserMaps(suffix<".a:suffix.">)")
  if exists("s:restoremap_{a:suffix}")
   let s:restoremap_{a:suffix}= substitute(s:restoremap_{a:suffix},'|\s*$','','e')
   if s:restoremap_{a:suffix} != ""
"   	call Decho("exe ".s:restoremap_{a:suffix})
    exe "silent! ".s:restoremap_{a:suffix}
   endif
   unlet s:restoremap_{a:suffix}
  endif
"  call Dret("RestoreUserMaps")
endfun

" ==============
"  Restore: {{{1
" ==============
let &cpo= s:keepcpo
unlet s:keepcpo

" ================
"  Modelines: {{{1
" ================
" vim: ts=4 fdm=marker
syntax/Decho.vim	[[[1
101
" DrChip's debugger syntax file
" Language   : DrChip's Dfunc/Decho/Dret output
" Maintainer : Charles E. Campbell, Jr.
" Last change: Aug 12, 2008
" Version    : 5

" Remove any old syntax stuff hanging around
syn clear

" DechoTab support
syn match	dechoTabTitleSep			"^---------$"
syn match	dechoTabTitle			"^Decho Tab$"

" Delimiters, strings, numbers
syn match   dechoDelimiter			"[{}]$"
syn match   dechoDelimiter			","
syn region  dechoAngleBrkt			oneline	matchgroup=Green	start="\w<"lc=1	matchgroup=Green	end=">" contains=dechoNotify,dechoAngleBrktInc,dechoString
syn region  dechoAngleBrktInc	contained	oneline				start="<"					end=">" contains=dechoNotify,dechoAngleBrktInc,dechoString
syn region  dechoString				oneline	matchgroup=Blue	start='"'		matchgroup=Blue	end='"' contains=dechoNotify
syn match   dechoNumber				"\<-\=[0-9]\+\>"
syn match   dechoNumber				"\<-\=[0-9]\+\ze:"
syn match   dechoNumber				"\<=-\=[0-9a-fA-F]\+\>"
syn match   dechoNumber				"\<[0-9a-fA-F]\+x$"
syn match   dechoNumber				"\<[0-9a-fA-F]\+x[^a-zA-Z=]"me=e-1

" Let me see errors/warnings/severe messages easily
syn keyword dechoNotify				fatal error severe
syn match   dechoNotify				"!!!\|???"
syn keyword	dechoWarning     			warning

" Bars, Function names, Return
syn match   dechoFunction contained		"\%([sS]:\)\=\h[a-zA-Z0-9_#]*"
syn match   dechoBar				"^|\+"
syn match   dechoStartFunc			"^|*\%([sS]:\)\=\h[a-zA-Z0-9_#]*("			contains=dechoBar,dechoFunction,dechoDelimStart
syn match   dechoStopFunc    			"^|\+return \%([sS]:\)\=\h[a-zA-Z0-9_#]*"		contains=dechoBar,dechoFunction
syn match   dechoComment     			"^[ \t]*#.*$"
syn match   dechoMatrix				"^|[-+ 0-9.e]\+|$"					contains=dechoMatrixBar
syn match   dechoMatrixBar contained	"|"

" Problems
syn keyword dechoProblem	PROBLEM[:]	COMBAK[:]	WARNING[:]	SEVERE[:]	NOTE[:]	DIFFER[S:]

if !exists("did_drchip_decho_syntax")
  let did_drchip_decho_syntax= 1

  " Links
  hi link dechoAngleBrktInc	dechoAngleBrkt

  " If the "Warning" highlighting group hasn't been defined,
  " then this script will define it.
  let s:id_hlname= hlID("Warning")
  let s:fg_hlname= synIDattr(synIDtrans(s:id_hlname),"fg")
  if s:id_hlname == 0 || s:fg_hlname == 0 || s:fg_hlname == -1
   hi Warning term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=yellow guifg=black guibg=yellow
  endif
  unlet s:id_hlname s:fg_hlname

  hi link dechoAngleBrkt	String
  hi link dechoComment		Comment
  hi link dechoDelimiter	Delimiter
  hi link dechoFunction		Statement
  hi link dechoMatrixBar	Delimiter
  hi link dechoNotify		Error
  hi link dechoNumber		Number
  hi link dechoProblem		Error
  hi link dechoString		String
  hi link dechoWarning		Warning
  hi link dechoTabTitle		PreProc
  hi link dechoTabTitleSep	Delimiter

  " HLTest: tests if a highlighting group has been set up {{{2
  fun! s:HLTest(hlname)
    let id_hlname= hlID(a:hlname)
    if id_hlname == 0
     return 0
    endif
    let id_trans = synIDtrans(id_hlname)
    if id_trans == 0
     return 0
    endif
    let fg_hlname= synIDattr(id_trans,"fg")
    let bg_hlname= synIDattr(id_trans,"bg")
    if fg_hlname == -1 && bg_hlname == -1
     return 0
    endif
    if fg_hlname == "" && bg_hlname == ""
     return 0
    endif
    return 1
  endfun

  " define DechoBarHL as needed
  if s:HLTest("Magenta")
   hi link DechoBarHL	Magenta
  else
   hi DechoBarHL	start=[m[35m stop=[m[32m	ctermfg=magenta	guifg=magenta term=none	cterm=none	gui=none
  endif
  delf s:HLTest
  hi link dechoBar     		DechoBarHL
endif
" vim: ts=6
doc/Decho.txt	[[[1
372
*decho.txt* Vim Code Debugger				Oct 23, 2008
*Decho.vim*

Author:  Charles E. Campbell, Jr.  <drNchipO@ScampbellPfamilyA.bizM>
	  (remove NOSPAM from Campbell's email to use)
Copyright: (c) 2004-2008 by Charles E. Campbell, Jr.	*decho-copyright*
           The VIM LICENSE applies to Decho.vim and Decho.txt
           (see |copyright|) except use "Decho" instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.


==============================================================================
1. Contents						*decho-contents*

	1. Contents......................: |decho-contents|
	2. Decho Manual..................: |decho|
	3. Decho Global Variables........: |decho-var|
	4. Decho History.................: |decho-history|

	NOTE: as of version 7, Decho requires <cecutil.vim> for
	:DechoOn and :DechoOff (they call SaveWinPosn() and
	RestoreWinPosn() to retain the cursor/screen position)


==============================================================================
2. Decho Manual						*decho* *dfunc* *dret*

	The Decho plugin supports the inlining of debugging code.  It allows
	one to store debugging information along with scripts.  Many of my]
	own scripts can use this plugin (usually after a :DechoOn is issued).

	Decho, Dfunc, Dret, and Dredir have several ways to save their
	debugging output: >

	 g:dechomode   To Enable   To Disable   Debugging Output
	 -----------   ----------  -----------  ---------------------------
	       1       (default)                appended to separate window
	       2       DechoMsgOn  DechoMsgOff  uses :echomsg
	       3       DechoVarOn  DechoVarOff  appended to g:dechovar
	       4       DechoRemOn  DechoRemOff  appended to a remote server
	       5       DechoTabOn  DechoTabOff  appended to a tab
<
	Why so many methods?  Although the default method, that of writing
	debugging output to a separate debugging window, is often quite
	convenient, sometimes plugins want to control the entire window
	display.  Hence a debugging window can cause trouble as it is
	unaccounted for by the plugin.  The :echomsg output can be seen with
	|:messages|, but only 20 such messages can be retained.  The remote
	server debugging output keeps its "distance" from plugins, but uses
	gvim to open a separate debugging instance.  So, pick whichever method
	suits debugging your plugin best.

	USAGE
>
	    call Decho("another string")
	    call Decho("yet","another","string")
	    call DechoSep(["extra message"])
	    call Dfunc("funcname(".whatever.")")
	    call Dredir(["string","string",...,]"cmd")
	    call Dret("funcname".whatever)
	    Decho "a string"
	    DechoMsgOff
	    DechoMsgOn
	    DechoOn    DechoOff
	    DechoRemOff
	    DechoRemOn
	    DechoTabOff
	    DechoTabOn
	    DechoVarOff
	    DechoVarOn [varname]
	    Dhide
	    Dshow
	    Dsep [extra-message]
<
	The Decho call will put the string(s) passed to it into the debugging
	window (by default, it will be called "DBG".  See |decho-var| for
	how to change that).  Control characters embedded in the string will
	be made visible with a ^A - ^Z transformation.

	The Dfunc() and Dret() calls act as a pair.  A function to be debugged
	should call, at entry, >

		call Dfunc("funcname("."any arguments".")")
<
	It should also call, just prior to any return point, >

		call Dret("funcname : any return values")
<	or just >
		call Dret("funcname")
<
	In between, calls to Decho will have their strings preceded by "|"s,
	one for every open Dfunc().  The Dret() will check to insure that it
	is apparently returning from the last function passed to Dfunc().

	Example: >
		function! MyFunction(x)
		  call Dfunc("MyFunction(x=".x.")")
		  ...
		  call Dret("MyFunction")
		endfunction
<
       							*DechoOn* *DechoOff*
	DechoOn and DechoOff are convenient commands for enabling and disabling
	Decho, Dfunc, and Dret calls in a sourcefile.  DechoOff makes any line
	containing one of the following strings: >

    	    Decho        DechoRemOff  DechoTabOn   Dfunc
    	    DechoMsgOff  DechoRemOn   DechoVarOff  Dret
    	    DechoMsgOn   DechoTabOff  DechoVarOn

<	into a comment line and DechoOn reactivates such commands by removing
	the leading comment '"' character.

	Example: >
		call Decho("this will show up in the DBG buffer")
<
						*decho-dhide* *decho-dshow*
	The Dhide and Dshow commands allow one to toggle the visibility of
	the DBG-buffer.  They use the g:decho_hide variable, plus make any
	current DBG-buffer hidden or visible as indicated.

	Usage: >
		:Dhide
		:Dshow
<
							*Dsep* *DechoSep*
	This command (Dsep) and function (call DechoSep([optional msg])
	places a line of the form >
		--sep#-- [optional message here]
<	in the debugging output.  The number will be incremented for each
	time this function is invoked.  It helps one correlate an action
	with the resulting debugging output.

							*decho-redir* *Dredir*
	The Dredir() function allows one to redirect (see |redir|) a command's
	output to the debugging buffer.  One must have the command to be
	executed as the first argument; optionally, one may include additional
	arguments which will be passed on to Decho() for output.

	Usage: >
		call Dredir(["string","string",...,]"cmd")
<
	Example: >
		call Dredir("buffers","ls!")
<
							*g:decho_bufenter*
	Some plugins use events such as BufEnter, WinEnter, and WinLeave.  If
	you set this variable to 1, then such events will be ignored when and
	only when Decho() and variants are used.  Setting this option avoids
	such plugins from being triggered when recording debugging messages.
	(examples: winmanager, taglist, multiselect, etc)

	Example: >
		let g:decho_bufenter= 1
<
						*DechoVarOn* *DechoVarOff*
	Although debugging to a window is often convenient for the programmer,
	unfortunately some vim applications are incompatible with such a
	window (such as those which do window control themselves).  Using >
		:DechoVarOn
<	sends debugging output to be appended to a variable named in the
	|g:dechovarname| variable (by default, its "g:dechovar").  To turn
	this mode off (ie. revert to normal debugging-window use) use >
		:DechoVarOff
<	DechoVarOn also sets g:dechofile with the name of the script that
	invoked it.
						*DechoMsgOn* *DechoMsgOff*
	This debugging method uses echomsg to display messages; they may be
	seen with the |:messages|.  Vim usually will retain up to 20 such
	messages (see |message-history|).  Use >
		:DechoMsgOn
<	to turn this method on and >
		:DechoMsgOff
<	to revert to normal debugging-window use.  This method helps avoid
	interference with some plugins.
	DechoMsgOn also sets g:dechofile with the name of the script that
	invoked it.

						*DechoRemOn* *DechoRemOff*
	This method will open (if necessary) and use a remote gvim with a
	servername of DECHOREMOTE.  Debugging messages are appended to that
	instance of gvim.  To have this command available, your vim must have
	|clientserver| enabled and |gvim| must be executable. Use >
		:DechoRemOn
<	to turn this method on and >
		:DechoRemOff
<	to revert to normal debugging-window use.  This method helps avoid
	interference with some plugins.

	DechoRemOn also sets g:dechofile with the name of the script that
	invoked it.

						*DechoTabOn* *DechoTabOff*
	This method will open (if necessary) and use a debugging tab with
	one window.  Debugging messages are appended to the debugging tab
	(see |tabpage|).  One may use |gt| to switch between two tabs.  Use >
		:DechoTabOn
<	to turn this method on and >
		:DechoTabOff
<	to revert to normal debugging-window use.  The Decho and related
	calls turn events off while writing to the debugging tab so as to
	attempt to remain transparent with respect to normal event processing.

	EXAMPLE

	Consider the following file: >
	    let x="abc"
	    let y="def"
	    call Dfunc("testing(x=".x.")")
	    call Decho("decho test #1")
	    call Dfunc("Testing(y=".y.")")
	    call Decho("decho test #2")
	    call Dret("Testing")
	    call Decho("decho test #3")
	    call Dret("testing")
<
	Then sourcing with <Decho.vim> as a plugin (ie. already loaded) yields: >

	    testing(x=abc) {
	    |decho test #1
	    |Testing(y=def) {
	    ||decho test #2
	    ||Testing }
	    |decho test #3
	    |testing }
<
	DechoRemOn also sets g:dechofile with the name of the script that
	invoked it.


==============================================================================
3. Decho Global Variables		*decho-variables* *decho_settings*
					*decho_options* *decho-var*

   *g:dechomode*      :	=1 use separate small window at bottom (default)
			=2 debugging messages will use echomsg and can be seen
			   by using :messages.  See |message-history| for more
			   about this; currently, the maximum number of mess-
			   ages remembered is 20.
			=3 debugging messages get appended to the variable
			   named by |g:dechovarname| (also see |g:dechovar|)
			=4 debugging messages get appended to the gvim remote
			   server named DECHOREMOTE.

   *g:decho_bufname*  :	by default "DBG" .  Sets the name of the debugging
   			buffer and window.
   *g:decho_hide*     :	if set the DBG window will be hidden and will
   			automatically "q" each time it is used.  To see it,
			:e DBG .  Useful for those applications that
			modify windows.
   *g:dechovar*       : default value of g:dechovarname (see |g:dechovarname|)

   *g:dechovarname*   : when g:dechomode is 3, debugging output is appended to
			the variable named by this variable
			(default: "g:dechovar"  - see |g:dechovar|)

							*decho_winheight*
   *g:decho_winheight* : by default equal to 5 lines.  Specifies the height
			 of the debugging window.  Every Dfunc/Decho/Dret
			 call will resize that window to this height.


==============================================================================
4. Decho History					*decho-history*

  v20 Jun 07, 2007 : * changed some syntax/Decho.vim highlighting definitions
		       to avoid the use of highlighting groups defined by
		       colors/astronaut.vim that aren't standard (Cyan,
		       Magenta) (pointed out by Andreas Politz)
		     * (Erik Falor) under windows, uses "start gvim..."so
		       that DechoRemOn doesn't keep the original gvim
		       blocking until the remote gvim closes.
		     * (Erik Falor) The remote gvim now has |'nosi'| sent to it.
      Feb 13, 2008   * changed s:DechoSep() to DechoSep() so that it can be
		       called externally.  In particular, I'm using (all one
		       line): >
		         redraw!|call DechoSep()|...
		         call inputsave()|call input("Press <cr> to continue")|...
		         call inputrestore()
<		       to put a temporary halt into code I'm debugging while
		       retaining an idea of where in the Debug file it took
		       effect.
      May 29, 2008   * Removed an annoying beep that could crop up if
                       g:dechotabnr indexed a non-existent tab page.
      Aug 12, 2008   * DechoRemOn left autoindent enabled in the remote
		       window which can cause staircasing
      Oct 13, 2008   * in DechoTab mode, the search for the first tab called
		       "Decho Tab" didn't start at tab#1 as the search loop
		       assumed.
  v19 Oct 16, 2006 : * Dredir now takes optional strings first instead of
		       last
		     * The :Decho and :Dredir commands now take <args> instead
		       of <q-args>, which allows them to act more like the
		       function calls do.
		     * DechoRemOn's remote vim no longer will have
		       formatoptions' a or t suboptions set even if the user
		       has specified something like fo+=at in his/her .vimrc.
		     * If the user interposes a new tab (or deletes the
		       "Decho Tab"), Decho finds the "Decho Tab" tab or
		       creates a new one when called.
  v18 Mar 13, 2006 : * now handles arguments which are lists
                     * works around ignorecase setting
		     * removed bt=nofile; using noswf instead
      Sep 08, 2006   * if DechoRemOn is used, but then the user closes the
                       remote window but still sends Decho messages, then
		       Decho now switches to DECHOWIN mode to prevent an
		       onslaught of error messages about how vim can't connect
		       to the DECHOREMOTE vim.
  v17 Mar 03, 2006 : * debugging filetype set to Decho for DechoTabOn and
                       DechoRemOn and ei manipulated so that syntax
		       highlighting works for the Decho Tab buffer.
		     * bugfix: when a buffer was |'noma'|, DechoTabOn
		       inherited that and complained about not being allowed
		       to modify the buffer.
  v16 Feb 27, 2006 : * reflecting changes to tab commands:
                       tab -> tabn, tabn -> tabnew
  v15 Feb 21, 2006 : * DechoTab[On\Off] implemented
  v14 Jan 25, 2006 : * bugfix: with DechoVarOn, Decho would issue error
                       messages when the string had single quotes (') in
		       it
		     * SaveWinPosn(0) used to avoid SWP stack use
      Feb 15, 2006   * DechoRemOn and DechoRemOff now turn debugging on/off to
		       a remote DECHOREMOTE gvim server.  Your vim must
		       support clientserver and gvim must be executable.
  v13 Jan 18, 2006 : * cecutil updated to use keepjumps
  v12 Jan 14, 2005 : * DechoOn/Off now also turns on/off DechoVarOn/Off
                     * Now includes a GetLatestVimScripts line for cecutil.vim
      Apr 25, 2005   * Decho now does "runtime plugin/cecutil.vim" if that plugin
                       hasn't been loaded yet.  It will also try the AsNeeded
		       subdirectory if g:loaded_asneeded exists.
      Jun 02, 2005   * with DechoMsgOn, Decho("doesn't") now works
  v11 Aug 06, 2004 : * <q-args> now used instead of <args> for :Decho and :Dredir
                       commands
      Oct 28, 2004   * DechoMsgOn and DechoMsgOff installed; debugging messages
                       will use the |echomsg| command.
      Dec 27, 2004   * DechoVarOn and DechoVarOff installed; debugging
      		       messages will be appended to the variable specified by
		       g:dechovarname, which by default is "g:dechovar".
		       These two commands toggle the variable
		       "g:dechovar_enabled".
      Dec 29, 2004   * Dredir() now accepts multiple arguments (cmd and output)
  v10 Jul 27, 2004 : * if g:decho_bufenter exists, Decho will ignore BufEnter
                       events
		     * Decho uses keepjumps to avoid altering the jumplist
		       table
		     * appending to the DBG buffer with Decho does not make
		       it modified
		     * Dredir(cmd) may be used to redirect command output
		       to the DBG buffer.  Example:  call Dredir("cmd")
   v9 Jun 18, 2004 : * Dfunc/Decho/Dret now immune to lcd changes in the DBG
   		       buffer name
                     * DechoOn and DechoOff now accept ranges
   v8 Jun 06, 2004 : * Implemented Dhide and Dshow commands for toggling
                       the DBG-buffer's visibility (see |decho_dhide|)
   v7 Jun 02, 2004 : * made creation of	DBG window silent
		     * g:decho_winheight implemented (see |decho_winheight|)
		     * Dfunc/Decho/Dret	will always resize the DBG window to the
		       number of lines specified by g:decho_winheight (dflt:5)
		     * g:decho_hide implemented (see |decho_hide|)
   v6 May 11, 2004 : * some bug	fixes
   v5 Apr 20, 2004 : * Dfunc() - for entering a	function
		     * Dret()  - for returning from a function
   v4 Apr 20, 2004 :   Now makes control characters visible
   v3 Aug 07, 2003 : * changed fixed "DBG" to g:decho_bufname to allow s/w to
		       change the buffer name!
		     * Now handles returning cursor to one of several windows
		       and having multiple DBG-windows


==============================================================================
vim:tw=78:ts=8:ft=help

