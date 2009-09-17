" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/LargeFile.vim	[[[1
80
" LargeFile: Sets up an autocmd to make editing large files work with celerity
"   Author:		Charles E. Campbell, Jr.
"   Date:		Sep 23, 2008
"   Version:	4
" GetLatestVimScripts: 1506 1 :AutoInstall: LargeFile.vim

" ---------------------------------------------------------------------
" Load Once: {{{1
if exists("g:loaded_LargeFile") || &cp
 finish
endif
let g:loaded_LargeFile = "v4"
let s:keepcpo          = &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Commands: {{{1
com! Unlarge			call s:Unlarge()
com! -bang Large		call s:LargeFile(<bang>0,expand("%"))

" ---------------------------------------------------------------------
"  Options: {{{1
if !exists("g:LargeFile")
 let g:LargeFile= 20	" in megabytes
endif

" ---------------------------------------------------------------------
"  LargeFile Autocmd: {{{1
" for large files: turns undo, syntax highlighting, undo off etc
" (based on vimtip#611)
augroup LargeFile
 au!
 au BufReadPre * call <SID>LargeFile(0,expand("<afile>"))
 au BufReadPost *
 \  if &ch < 2 && (getfsize(expand("<afile>")) >= g:LargeFile*1024*1024 || getfsize(expand("<afile>")) == -2)
 \|  echomsg "***note*** handling a large file"
 \| endif
augroup END

" ---------------------------------------------------------------------
" s:LargeFile: {{{2
fun! s:LargeFile(force,fname)
"  call Dfunc("LargeFile(force=".a:force." fname<".a:fname.">)")
  if a:force || getfsize(a:fname) >= g:LargeFile*1024*1024 || getfsize(a:fname) <= -2
   syn clear
   let b:eikeep = &ei
   let b:ulkeep = &ul
   let b:bhkeep = &bh
   let b:fdmkeep= &fdm
   let b:swfkeep= &swf
   set ei=FileType
   setlocal noswf bh=unload fdm=manual ul=-1
   let fname=escape(substitute(a:fname,'\','/','g'),' ')
   exe "au LargeFile BufEnter ".fname." set ul=-1"
   exe "au LargeFile BufLeave ".fname." let &ul=".b:ulkeep."|set ei=".b:eikeep
   exe "au LargeFile BufUnload ".fname." au! LargeFile * ". fname
   echomsg "***note*** handling a large file"
  endif
"  call Dret("s:LargeFile")
endfun

" ---------------------------------------------------------------------
" s:Unlarge: this function will undo what the LargeFile autocmd does {{{2
fun! s:Unlarge()
"  call Dfunc("s:Unlarge()")
  if exists("b:eikeep") |let &ei  = b:eikeep |endif
  if exists("b:ulkeep") |let &ul  = b:ulkeep |endif
  if exists("b:bhkeep") |let &bh  = b:bhkeep |endif
  if exists("b:fdmkeep")|let &fdm = b:fdmkeep|endif
  if exists("b:swfkeep")|let &swf = b:swfkeep|endif
  syn on
  doau FileType
"  call Dret("s:Unlarge")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
doc/LargeFile.txt	[[[1
55
*LargeFile.txt*	Editing Large Files Quickly			Sep 23, 2008

Author:  Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email first)
Copyright: (c) 2004-2008 by Charles E. Campbell, Jr.	*LargeFile-copyright*
           The VIM LICENSE applies to LargeFile.vim
           (see |copyright|) except use "LargeFile" instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.

==============================================================================
1. Large File Plugin						*largefile* {{{1

The LargeFile plugin is fairly short -- it simply sets up an |autocmd| that
checks for large files.  There is one parameter: >
	g:LargeFile
which, by default, is 20MB.  Thus with this value of g:LargeFile, 20MByte
files and larger are considered to be "large files"; smaller ones aren't.  Of
course, you as a user may set g:LargeFile to whatever you want in your
<.vimrc> (in units of MBytes).

LargeFile.vim always assumes that when the file size is larger than what
can fit into a signed integer (2^31, ie. about 2GB) that the file is "Large".

Basically, this autocmd simply turns off a number of features in Vim,
including event handling, undo, and syntax highlighting, in the interest of
speed and responsiveness.

LargeFile.vim borrows from vimtip#611.

To undo what LargeFile does, type >
	:Unlarge
<
To redo what LargeFile does, type >
	:Large
<
Note that LargeFile cannot alleviate hardware limitations; vim on 32-bit
machines are limited to editing 2G files.  If your vim is compiled on a 64-bit
machine such that it can take advantage of the additional address space, then
presumably vim could edit up to 9.7 quadrillion byte files (not that I've ever
tried that!).

==============================================================================
2. History						*largefile-history* {{{1

  4 : Jan 03, 2008 * made LargeFile.vim :AutoInstall:-able by getscript
      Apr 11, 2008 * (Daniel Shahaf suggested) that :Large! do the large-file
                     handling irregardless of file size.  Implemented.
      Sep 23, 2008 * if getfsize() returns -2 then the file is assumed to be
		     large
  3 : May 24, 2007 * Unlarge command included
                   * If getfsize() returns something less than -1, then it
		     will automatically be assumed to be a large file.

==============================================================================
vim:tw=78:ts=8:ft=help:fdm=marker:
