" Vim syntax file
" Language:	GTD
" Maintainer:	William Bartholomew <william@bartholomew.id.au>
" Last Change:	2006-05-25

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

"Although there are few non-symbol characters in this syntax, there isn't
"any reason for it to be case-sensitive.
syntax case ignore

syn region gtdDone start="^x[ :]" end="$"
syn region gtdProject start="^p:" end="\s"
syn region gtdContext start="@" end="\s\|$" contains=gtdContextClassifier
syn match gtdContextClassifier contained /:\S\+/hs=s+1
syn match gtdCreateTimestamp /\[\d\{8}\]$/

hi def link gtdProject Statement
hi def link gtdContext Type
hi def link gtdContextClassifier Identifier
hi def link gtdDone Comment
hi def link gtdCreateTimestamp Comment

let b:current_syntax = "gtd"
