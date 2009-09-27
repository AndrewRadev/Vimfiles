" Script Name: LineCommenter.vim
" Version:     2.0.0
" Last Change: Nov 12, 2008
" Author:      XSQ <xsq0304@qq.com>
"
" Description: Toggle Comment state of line.(C/C++/Java/perl/python/ruby/etc.)
" Usage:       Press '<Esc>cc' to toggle comment state of the current line
"              Press '<Esc>ncc' to toggle n straight lines.
" File Type:   Over 104 languages
"   //:        C, C++, java, javascript, etc.
"   #:         awk, makefile, perl, python, ruby, sed, sh, etc.
"   ":         vim
"   ':         asp, basic, vbscript
"   ;:         asm, ini, etc.
"   rem :      bat
"   --:        sql, etc.
"   %:         matlab, tex, etc.
" Install:     Just drop this script file into vim's plugin directory.

nmap <silent>cc :call LineCommenter()<Esc>


function GetCommenter(StringKey)
  let s:DictCommenters = {'abap':['\*',''], 'abc':['%',''], 'ada':['--',''], 'apache':['#',''], 'asm':[';',''], 'aspvbs':['''',''], 'asterisk':[';',''], 'awk':['#',''], 'basic':['''',''], 'bcpl':['//',''], 'c':['//',''], 'cecil':['--',''], 'cfg':['#',''], 'clean':['//',''], 'cmake':['#',''], 'cobol':['\*',''], 'cpp':['//',''], 'cs':['//',''], 'css':['/\*','\*/'], 'cxx':['//',''], 'd':['//',''], 'debcontrol':['#',''], 'diff':['#',''], 'dosbatch':['rem ',''], 'dosini':[';',''], 'dtml':['<!--','-->'], 'dylan':['//',''], 'e':['#',''], 'eiffel':['--',''], 'erlang':['%',''], 'euphora':['--',''], 'forth':['\',''], 'fortran':['!',''], 'foxpro':['\*',''], 'fs':['//',''], 'groovy':['//',''], 'grub':['#',''], 'h':['//',''], 'haskell':['--',''], 'hpp':['//',''], 'html':['<!--','-->'], 'htmldjango':['<!--','-->'], 'htmlm4':['<!--','-->'], 'icon':['#',''], 'io':['#',''], 'j':['NB.',''], 'java':['//',''], 'javascript':['//',''], 'lex':['//',''], 'lhaskell':['%',''], 'lilo':['#',''], 'lisp':[';',''], 'logo':[';',''], 'lua':['--',''], 'make':['#',''], 'matlab':['%',''], 'maple':['#',''], 'merd':['#',''], 'mma':['(\*','\*)'], 'modula3':['(\*','\*)'], 'mumps':[';',''], 'natural':['\*',''], 'nemerle':['//',''], 'objc':['//',''], 'objcpp':['//',''], 'ocaml':['(\*','\*)'], 'oz':['%',''], 'pascal':['{','}'], 'perl':['#',''], 'php':['//',''], 'pike':['//',''], 'pliant':['#',''], 'plsql':['--',''], 'postscr':['%',''], 'prolog':['%',''], 'python':['#',''], 'rebol':[';',''], 'rexx':['/\*','\*/'], 'ruby':['#',''], 'sas':['/\*','\*/'], 'sather':['--',''], 'scala':['//',''], 'scheme':[';',''], 'sed':['#',''], 'sgml':['<!--','-->'], 'sh':['#',''], 'sieve':['#',''], 'simula':['--',''], 'sql':['--',''], 'st':['"','"'], 'tcl':['#',''], 'tex':['%',''], 'vb':['''',''], 'vhdl':['--',''], 'vim':['"',''], 'xf86conf':['#',''], 'xhtml':['<!--','-->'], 'xml':['<!--','-->'], 'xquery':['<!--','-->'], 'xsd':['<!--','-->'], 'yacc':['//',''], 'yaml':['#',''], 'ycp':['//',''], 'yorick':['//','']}

  if has_key(s:DictCommenters, a:StringKey)
    return s:DictCommenters[a:StringKey]
  else
    return ['', '']
  endif
endfunction


function GetHeadOfLineWithSpace(Commenter)
  let s:CurrentLine = getline(".")
  let s:Words = split(s:CurrentLine, "\ ")
  let s:LengthOfCommenter = strlen(a:Commenter)
  if empty(s:Words) || strlen(s:Words[0]) != s:LengthOfCommenter - 1
    return ''
  else
    let s:WordsOfCommenter = split(a:Commenter, "\ ")
    let s:CommenterWithoutSpace = s:WordsOfCommenter[0]
    if tolower(s:CurrentLine) == s:CommenterWithoutSpace
      call setline(".", a:Commenter)
      let s:HeadOfLine = a:Commenter
    else
      let s:HeadOfLine = s:Words[0] . ' '
    endif
    return s:HeadOfLine
  endif
endfunction


function GetHeadOfLine(Commenter)
  let s:CurrentLine = getline(".")
  let s:Words = split(getline("."), "\ ")
  let s:LengthOfCommenter = strlen(a:Commenter)
  if empty(s:Words) || strlen(s:Words[0]) < s:LengthOfCommenter
    return ''
  else
    let s:HeadOfLine = ''
    let s:FirstWord = s:Words[0]
    for i in range(s:LengthOfCommenter)
      let s:HeadOfLine = s:HeadOfLine . s:FirstWord[i]
    endfor
    return s:HeadOfLine
  endif
endfunction


function LineCommenter()
  let s:ListCommenter = GetCommenter(&ft)

  if s:ListCommenter[0] == ''
    echo "." . &ft . " file is not supported."

  elseif s:ListCommenter[1] == ''
    let s:Commenter = s:ListCommenter[0]
    if s:Commenter[strlen(s:Commenter) - 1] == ' '
      let s:HeadOfLine = GetHeadOfLineWithSpace(s:Commenter)
    else
      let s:HeadOfLine = GetHeadOfLine(s:Commenter)
    endif

    let s:CurrentLine = getline(".")
    if s:HeadOfLine == s:Commenter
      let s:NewLine = substitute(s:CurrentLine, s:Commenter, "", "")
    else
      let s:NewLine = s:Commenter . s:CurrentLine
    endif
    call setline(".", s:NewLine)

  else
    echo "Block Comment has not been supported yet."
  endif
endfunction
