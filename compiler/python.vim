" vim compiler file
" Compiler:		Python     
" Maintainer:   Mikhail Wolfson <mywolfson-at-gmail-com>
" Last Change:  05 April 2010

if exists("current_compiler")
  finish
endif
let current_compiler = "python"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

"Make python send everything to stdout, then weed out empty lines with grep."
CompilerSet makeprg=python\ -uc\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"\\\|grep\ -v\ \"^$\"

"So far only seen SyntaxError, but, in principle, could be anything
CompilerSet errorformat=%\\w%#%trror:\ ('%m'\\,\ ('%f'\\,\ %l\\,\ %c\\,\ '%.%#'))
 
let &cpo = s:cpo_save
unlet s:cpo_save

"vim: ft=vim
