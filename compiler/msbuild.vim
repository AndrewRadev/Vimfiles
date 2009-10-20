" Vim compiler file
" Compiler:	msbuild C#
" Maintainer:	Red Forks (redforks@gmail.com)
" Last Change:	2005 Dec 25
" 
" Note: Add Follow line to your .csproj file's common PropertyGroup
" <GenerateFullPaths>True</GenerateFullPaths>

if exists("current_compiler")
  finish
endif
let current_compiler = "msbuild"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

" errorformat for csc
CompilerSet errorformat=%f(%l\\,%c):\ %t%*[^\ ]\ CS%n:\ %m

" default make
CompilerSet makeprg=msbuild.exe\ /nologo\ /v:q
