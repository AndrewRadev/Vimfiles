" Vim compiler file
" Compiler:	    Mono C#
" Maintainer:	Erik Falor (ewfalor@gmail.com)
" Last Change:	2007 May 24
" Version:      1.2.1

if exists("current_compiler")
  finish
endif
let current_compiler = "gmcs"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

" default errorformat

CompilerSet errorformat=
	\%*[^\"]\"%f\"%*\\D%l:\ %m,
	\\"%f\"%*\\D%l:\ %m,
	\%f(%l\\,%c):\ %trror\ CS%\\d%\\+:\ %m,
	\%f(%l\\,%c):\ %tarning\ CS%\\d%\\+:\ %m,
	\%f:%l:\ %m,
	\\"%f\"\\,\ line\ %l%*\\D%c%*[^\ ]\ %m,
	\%D%*\\a[%*\\d]:\ Entering\ directory\ `%f',
	\%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f',
	\%DMaking\ %*\\a\ in\ %f,
	\%-G%.%#Compilation%.%#,
	\%-G%.%#

" default make
CompilerSet makeprg=gmcs\ %
"CompilerSet makeprg=make
