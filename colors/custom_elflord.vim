" vim: tw=0 ts=4 sw=4

set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "custom_elflord"

hi lCursor guibg=red

hi Comment      term=bold       ctermfg=DarkCyan    guifg=#80a0ff
hi Constant     term=underline  ctermfg=Magenta     guifg=Magenta
hi CursorLine   cterm=underline gui=underline       guibg=Black
hi DiffAdd      cterm=none      ctermbg=235         guibg=#262626
hi DiffChange   cterm=none      ctermbg=235         guibg=#262626
hi DiffDelete   cterm=none      ctermfg=238         ctermbg=244   guibg=#808080 guifg=#444444
hi DiffText     cterm=bold      ctermfg=255         ctermbg=196   guifg=#ffffff
hi Directory    cterm=none      ctermfg=Green       guifg=Green
hi Error        term=reverse    ctermbg=Red         ctermfg=White guibg=Red     guifg=White
hi Function     term=bold       ctermfg=Cyan        guifg=Cyan
hi Identifier   term=underline  ctermfg=Cyan        guifg=#40ffff
hi Ignore       ctermfg=black   guifg=bg
hi Normal       cterm=none      guifg=#dddddd       ctermfg=white guibg=black
hi Operator     ctermfg=Red     guifg=Red
hi Pmenu        cterm=none      ctermfg=255         ctermbg=235   guibg=#262626 guifg=#ffffff
hi PmenuSbar    cterm=none      ctermfg=240         ctermbg=240   guibg=#444444
hi PmenuSel     cterm=none      ctermfg=255         ctermbg=21    guibg=#0000ff guifg=#ffffff
hi PmenuThumb   cterm=none      ctermfg=255         ctermbg=255   guifg=#ffffff
hi PreProc      term=underline  ctermfg=LightBlue   guifg=#ff80ff
hi Repeat       term=underline  ctermfg=White       guifg=white
hi Special      term=bold       ctermfg=DarkMagenta guifg=Red
hi Statement    term=bold       ctermfg=Yellow      gui=bold      guifg=#aa4444

" Get visual mode working for my new Mac, temporary
" (Might be useful having a red visual selection, though, need to consider)
hi Visual      guibg=#557799  guifg=white    gui=none ctermbg=9 ctermfg=15

" Status Line
" -----------
" status line for current window
"hi StatusLine       guifg=#e0e0e0           guibg=#363946           gui=bold
"hi StatusLine       ctermfg=254             ctermbg=237             cterm=bold
"hi StatusLine       guifg=#e0e0e0           guibg=#000000           gui=bold
"hi StatusLine       ctermfg=254             ctermbg=none             cterm=bold

" Try without fading, underline active instead
hi StatusLine   ctermfg=white ctermbg=none cterm=bold,underline
hi StatusLine   guifg=white   guibg=#000000   gui=bold,underline
hi StatusLineNC ctermfg=white ctermbg=none cterm=none
hi StatusLineNC guifg=white   guibg=#000000   gui=none

" status line for non-current windows
"hi StatusLineNC     guifg=#767986           guibg=#363946           gui=none
"hi StatusLineNC     ctermfg=244             ctermbg=237             cterm=none
"hi StatusLineNC     guifg=#767986           guibg=#000000           gui=none
"hi StatusLineNC     ctermfg=244             ctermbg=none             cterm=none

" Tab Lines
" ---------
" tab pages line, not active tab page label
hi TabLine          guifg=#b6bf98           guibg=#363946           gui=none
hi TabLine          ctermfg=244             ctermbg=236             cterm=none
" tab pages line, where there are no labels
hi TabLineFill      guifg=#cfcfaf           guibg=#363946           gui=none
hi TabLineFill      ctermfg=187             ctermbg=236             cterm=none
" tab pages line, active tab page label
hi TabLineSel       guifg=#efefef           guibg=#414658           gui=bold
hi TabLineSel       ctermfg=254             ctermbg=236             cterm=bold

" Folds
" -----
" line used for closed folds
hi Folded           guifg=#91d6f8           guibg=#363946           gui=none
hi Folded           ctermfg=14             ctermbg=238             cterm=none
"hi Folded           ctermfg=117             ctermbg=238             cterm=none
" column on side used to indicated open and closed folds
hi FoldColumn       guifg=#91d6f8           guibg=#363946           gui=none
hi FoldColumn       ctermfg=14             ctermbg=238             cterm=none
"hi FoldColumn       ctermfg=117             ctermbg=238             cterm=none

hi Todo             guifg=#efef8f           guibg=NONE              gui=underline
hi Todo             ctermfg=228             ctermbg=NONE            cterm=underline

hi Type       term=underline ctermfg=LightGreen guifg=#60ff60        gui=bold
hi VertSplit  cterm=none     ctermfg=254        guifg=#ffffff        gui=none
hi WildMenu   guifg=#ee1111  guibg=#000000         gui=bold,underline
hi WildMenu   ctermfg=196    ctermbg=none       cterm=bold,underline
hi SignColumn cterm=none     ctermbg=none       ctermfg=White        guibg=#000000

" match parenthesis, brackets
hi MatchParen guifg=#00ff00 guibg=NONE   gui=none
hi MatchParen ctermfg=Green ctermbg=NONE cterm=none

"hi NonText cterm=NONE ctermfg=NONE

" Common groups that link to default highlighting.
" You can specify other highlighting easily.
hi link String          Constant
hi link Character       Constant
hi link Number          Constant
hi link Boolean         Constant
hi link Float           Number
hi link Conditional     Repeat
hi link Label           Statement
hi link Keyword         Statement
hi link Exception       Statement
hi link Include         PreProc
hi link Define          PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef         Type
hi link Tag             Special
hi link SpecialChar     Special
hi link Delimiter       Special
hi link SpecialComment  Special
hi link Debug           Special
