" Vim compiler file
" Compiler:     PHP CodeSniffer
" Last Change:  March 26, 2010

if exists("current_compiler")
  finish
endif
let current_compiler = "phpcs"

if exists(":CompilerSet") != 2    " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=phpcs\ --report=csv\ --standard=Zend\ %:p

CompilerSet errorformat=\"%f\"\\,%l\\,%c\\,%t%*[a-zA-Z]\\,\"%m\"%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
