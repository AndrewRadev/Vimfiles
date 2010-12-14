"runtime! syntax/txt.vim
"unlet b:current_syntax

syn match rspecGreen /^-.*$/
syn match rspecRed /^-.*(FAILED - \d\+)$/
syn match rspecRed /^.*FAILED$/

syn match rspecRed /\d\+ examples, \d\+ failures/
syn match rspecGreen /\d\+ examples, 0 failures/

syn match Underlined /^\f\+:\d\+/

hi rspecRed   ctermfg=Red   guifg=Red
hi rspecGreen ctermfg=Green guifg=Green

" TODO: Pending
