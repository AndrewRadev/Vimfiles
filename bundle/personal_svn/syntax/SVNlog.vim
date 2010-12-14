syn match svnLogDelimiter   /------/
syn match svnRevisionString /r\d\+/
syn match svnPipe           /|/

syn match svnStatusAdded    /^\s\+A\s/
syn match svnStatusModified /^\s\+M\s/
syn match svnStatusDeleted  /^\s\+D\s/

hi link svnLogDelimiter   Delimiter
hi link svnRevisionString Underlined
hi link svnPipe           Operator
" Very arbitrary, matching my own color theme...
hi link svnStatusAdded    Type
hi link svnStatusModified Statement
hi link svnStatusDeleted  Operator
