" Vim compiler file
" Compiler:      Miscrosoft C#
" Maintainer:    Mark Feeney <vim|AT|markfeeney|DOT|com>
" Last Change:   $Id: csc.vim,v 1.3 2002/04/05 17:04:11 markf Exp $
"
" NOTES:
"  You must use my build setup to get this to work correctly.  Right now it's
"  fairly primitive, but it works.  Put all your compiler flags and settings
"  in a file called make.rsp in the same directory as your source files.  This
"  compiler file calls the compiler like so:
"
"  csc /fullpaths @make.rsp
"
" Sample make.rsp (from a project of mine):
"
"  +- begin make.rsp --------------------------+
"  /debug-
"  /nologo
"  /target:library
"  /out:..\bin\TimeTracker.dll
"  DBBase.cs
"  DBProjectCategories.cs
"  DBProjects.cs
"  DBUsers.cs
"  ProjectCategories.cs
"  Projects.cs
"  Users.cs
"  +- end make.rsp ----------------------------+
"
"  There are probably better ways to set this up; feel free to contact me if
"  you know of one.  This has worked well for me so far though.
"
" INSTALLATION:
"
" Copy csc.vim to c:\vim\vimfiles\compiler and then add an autocommand like
" this to your _vimrc:
"
" au BufNewFile,BufRead *.cs compiler csc
"

if exists("current_compiler")
  finish
endif
let current_compiler = "csc"

setlocal makeprg=csc\ /fullpaths\ @make.rsp
setlocal errorformat=%f(%l\\,%c):\ error\ CS%n:\ %m

