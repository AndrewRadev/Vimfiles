" histwin.vim - Vim global plugin for browsing the undo tree
" -------------------------------------------------------------
" Last Change: 2010, Jan 20
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Version:     0.7.2
" Copyright:   (c) 2009 by Christian Brabandt
"              The VIM LICENSE applies to histwin.vim 
"              (see |copyright|) except use "histwin.vim" 
"              instead of "Vim".
"              No warranty, express or implied.
"    *** ***   Use At-Your-Own-Risk!   *** ***
"
" GetLatestVimScripts: 2932 1 :AutoInstall: histwin.vim
" TODO: - write documentation
"       - don't use matchadd for syntax highlighting but use
"         appropriate syntax highlighting rules

" Init:
if exists("g:loaded_undo_browse") || &cp || &ul == -1
  finish
endif

let g:loaded_undo_browse = 1
let s:cpo                = &cpo
set cpo&vim

" User_Command:
if exists(":UB") != 2
	com -nargs=0 UB :call histwin#UndoBrowse()
else
	echoerr ":UB is already defined. May be by another Plugin?"
endif

" ChangeLog:
" 0.7.2   - make sure, when switching to a different undo-branch, the undo-tree will be reloaded
"         - check 'undolevel' settings  
" 0.7.1   - fixed a problem with mapping the keys which broke the Undo-Tree keys
"           (I guess I don't fully understand, when to use s: and <sid>)
" 0.7     - created autoloadPlugin (patch by Charles Campbell) Thanks!
"         - enabled GLVS (patch by Charles Campbell) Thanks!
"         - cleaned up old comments
"         - deleted :noautocmd which could cause trouble with other plugins
"         - small changes in coding style (<sid> to s:, fun instead of fu)
"         - made Plugin available as histwin.vba
"         - Check for availability of :UB before defining it
"           (could already by defined Blockquote.vim does for example)
" 0.6     - fix missing bufname() when creating the undo_tree window
"		  - make undo_tree window a little bit smaller
"		    (size is adjustable via g:undo_tree_wdth variable)
" 0.5     - add missing endif (which made version 0.4 unusuable)
" 0.4     - Allow diffing with selected branch
"         - highlight current version
"         - Fix annoying bug, that displays 
"           --No lines in buffer--
" 0.3     - Use changenr() to determine undobranch
"         - <C-L> updates view
"         - allow switching to initial load state, before
"           buffer was edited

" Restore:
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\" spell spelllang=en fdm=syntax
