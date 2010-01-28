" Vim syntax file
" Language:	GTD file remarks
" Maintainer:	Francisco Garcia Rodriguez <contact@francisco-garcia.net>
" Last Change:	2005 Jun 20

runtime! syntax/pnote.vim

syn match       NOSPELL1        "\<\u\+\>" contains=@NoSpell
syn match       NOSPELL2        "\S*[:\=]\S*" contains=@NoSpell
syn match       NOSPELL3        "\S\+=\S\+" contains=@NoSpell

syn match       TASK            "\s@\w*" contains=@NoSpell
syn match       PROJECT         "\sp\(:\w*\)\+" contains=@NoSpell

" Project names must be written in a x4 column
syn match       PROJECT         "^\(\s\{4}\)\+\u\(\u\|\d\|_\)\+"
syn match       LIST            "^\s\+[-\*]"

syn match       PROTOCOL        "\w\+::" nextgroup=URL,USERNAME contains=@NoSpell
syn match       URL             "\S\+" contained contains=@NoSpell
syn match       USERNAME        "\S\+@" contained nextgroup=URL contains=@NoSpell

"syn match       DATE            "\d\{4}-\d\d-\d\d"hs=s+4
syn match       DATE            "\d\{4}-\d\d-\d\d"

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi TASK guifg=lightgreen
hi PROJECT guifg=lightred
hi LIST guifg=magenta
hi MARK guifg=lightcyan
hi PROTOCOL guifg=lightmagenta 
hi URL guifg=lightcyan gui=underline
hi USERNAME guifg=lightblue
hi DATE guifg=lightred
syn cluster GTDHI add=TASK,MARK,PROTOCOL,URL,USERNAME

" vim: ts=8 sw=2
