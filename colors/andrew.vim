set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "andrew"

hi lCursor guibg=Red

hi Comment      term=bold       ctermfg=DarkCyan    guifg=#80a0ff
hi Constant     term=underline  ctermfg=Magenta     guifg=Magenta
hi CursorLine   cterm=underline gui=underline       guibg=Black
hi DiffAdd      cterm=NONE      ctermbg=235         guibg=#262626
hi DiffChange   cterm=NONE      ctermbg=235         guibg=#262626
hi DiffDelete   cterm=NONE      ctermfg=238         ctermbg=244   guibg=#808080 guifg=#444444
hi DiffText     cterm=bold      ctermfg=255         ctermbg=196   guifg=#ffffff
hi Directory    cterm=NONE      ctermfg=Green       guifg=Green
hi Error        term=reverse    ctermbg=Red         ctermfg=White guibg=red     guifg=White
hi Function     term=bold       ctermfg=Cyan        guifg=Cyan
hi Identifier   term=underline  ctermfg=Cyan        guifg=#40ffff
hi Ignore       ctermfg=Black   guifg=bg
hi Normal       cterm=NONE      guifg=#dddddd       ctermfg=White guibg=Black
hi Operator     ctermfg=Red     guifg=red
hi Pmenu        cterm=NONE      ctermfg=255         ctermbg=235   guibg=#262626 guifg=#ffffff
hi PmenuSbar    cterm=NONE      ctermfg=240         ctermbg=240   guibg=#444444
hi PmenuSel     cterm=NONE      ctermfg=255         ctermbg=21    guibg=#0000ff guifg=#ffffff
hi PmenuThumb   cterm=NONE      ctermfg=255         ctermbg=255   guifg=#ffffff
hi PreProc      term=underline  ctermfg=LightBlue   guifg=#ff80ff
hi Repeat       term=underline  ctermfg=White       guifg=White
hi Special      term=bold       ctermfg=DarkMagenta guifg=Red
hi Statement    term=bold       ctermfg=Yellow      gui=bold      guifg=#aa4444

" Red visual selection
hi Visual      guibg=Red  guifg=White    gui=NONE ctermbg=red ctermfg=White

" Slim separator lines
hi StatusLine   ctermfg=White ctermbg=NONE cterm=bold
hi StatusLine   guifg=White guibg=#000000 gui=bold
hi StatusLineNC ctermfg=White ctermbg=NONE cterm=NONE
hi StatusLineNC guifg=White guibg=#000000 gui=NONE
hi VertSplit    guifg=White cterm=NONE ctermfg=White gui=NONE

" Tab Lines
" ---------
" tab pages line, inactive tab page label
hi TabLine          guifg=#b6bf98           guibg=#363946           gui=NONE
hi TabLine          ctermfg=244             ctermbg=236             cterm=NONE
" tab pages line, where there are no labels
hi TabLineFill      guifg=#cfcfaf           guibg=#363946           gui=NONE
hi TabLineFill      ctermfg=187             ctermbg=236             cterm=NONE
" tab pages line, active tab page label
hi TabLineSel       guifg=#efefef           guibg=#414658           gui=bold
hi TabLineSel       ctermfg=254             ctermbg=236             cterm=bold

" Folds
" -----
" line used for closed folds
hi Folded           guifg=#91d6f8           guibg=#363946           gui=NONE
hi Folded           ctermfg=14             ctermbg=238             cterm=NONE
" column on side used to indicate open and closed folds
hi FoldColumn       guifg=#91d6f8           guibg=#363946           gui=NONE
hi FoldColumn       ctermfg=14             ctermbg=238             cterm=NONE

hi Todo             guifg=#efef8f           guibg=NONE              gui=underline
hi Todo             ctermfg=228             ctermbg=NONE            cterm=underline

hi Type       term=underline ctermfg=LightGreen guifg=#60ff60        gui=bold
hi WildMenu   guifg=#ee1111  guibg=#000000         gui=bold,underline
hi WildMenu   ctermfg=196    ctermbg=NONE       cterm=bold,underline
hi SignColumn cterm=NONE     ctermbg=NONE       ctermfg=White        guibg=#000000

" match parentheses, brackets
hi MatchParen guifg=#00ff00 guibg=NONE   gui=NONE
hi MatchParen ctermfg=Green ctermbg=NONE cterm=NONE

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
