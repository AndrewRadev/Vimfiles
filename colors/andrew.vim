set background=dark
hi clear

if exists("syntax_on")
 syntax reset
endif

let g:colors_name = "andrew"

hi lCursor guibg=Red

hi Comment term=bold
hi Comment ctermfg=DarkCyan
hi Comment guifg=#80a0ff

hi Constant term=underline
hi Constant ctermfg=Magenta
hi Constant guifg=Magenta

hi CursorLine cterm=underline
hi CursorLine gui=underline guibg=Black

hi DiffAdd cterm=NONE ctermbg=235
hi DiffAdd guibg=#262626

hi DiffChange cterm=NONE ctermbg=235
hi DiffChange guibg=#262626

hi DiffDelete cterm=NONE ctermfg=238 ctermbg=244
hi DiffDelete guibg=#808080 guifg=#444444

hi DiffText cterm=bold ctermfg=255 ctermbg=196
hi DiffText guifg=#ffffff

hi Directory cterm=NONE ctermfg=Green
hi Directory guifg=Green

hi Error term=reverse
hi Error ctermbg=Red ctermfg=White
hi Error guibg=Red guifg=White

hi Function term=bold
hi Function ctermfg=Cyan
hi Function guifg=Cyan

hi Identifier term=underline
hi Identifier ctermfg=Cyan
hi Identifier guifg=#40ffff

hi Ignore ctermfg=Black
hi Ignore guifg=bg

hi Normal cterm=NONE ctermfg=White
hi Normal guifg=#dddddd guibg=Black

hi Operator ctermfg=Red
hi Operator guifg=Red

hi Pmenu cterm=NONE ctermfg=255 ctermbg=235
hi Pmenu guibg=#262626 guifg=#ffffff

hi PmenuSbar cterm=NONE ctermfg=240 ctermbg=240
hi PmenuSbar guibg=#444444

hi PmenuSel cterm=NONE ctermfg=255 ctermbg=21
hi PmenuSel guibg=#0000ff guifg=#ffffff

hi PmenuThumb cterm=NONE ctermfg=255 ctermbg=255
hi PmenuThumb guifg=#ffffff

hi PreProc term=underline
hi PreProc ctermfg=LightBlue
hi PreProc guifg=#ff80ff

hi Repeat term=underline
hi Repeat ctermfg=White
hi Repeat guifg=White

hi Special term=bold
hi Special ctermfg=DarkMagenta
hi Special guifg=Red

hi Statement term=bold
hi Statement ctermfg=Yellow
hi Statement gui=bold guifg=#aa4444

" Red visual selection
hi Visual ctermbg=Red ctermfg=White
hi Visual guibg=Red guifg=White gui=NONE

" Slim separator lines
hi StatusLine ctermfg=White ctermbg=NONE cterm=bold
hi StatusLine guifg=White guibg=#000000 gui=bold

hi StatusLineNC ctermfg=White ctermbg=NONE cterm=NONE
hi StatusLineNC guifg=White guibg=#000000 gui=NONE

hi VertSplit cterm=NONE ctermfg=White
hi VertSplit guifg=White gui=NONE

" Tab Lines

hi TabLine ctermfg=244 ctermbg=236 cterm=NONE
hi TabLine guifg=#b6bf98 guibg=#363946 gui=NONE

hi TabLineFill ctermfg=187 ctermbg=236 cterm=NONE
hi TabLineFill guifg=#cfcfaf guibg=#363946 gui=NONE

hi TabLineSel ctermfg=254 ctermbg=236 cterm=bold
hi TabLineSel guifg=#efefef guibg=#414658 gui=bold

" Folds

hi Folded ctermfg=14 ctermbg=238 cterm=NONE
hi Folded guifg=#91d6f8 guibg=#363946 gui=NONE

hi FoldColumn ctermfg=14 ctermbg=238 cterm=NONE
hi FoldColumn guifg=#91d6f8 guibg=#363946 gui=NONE

hi Todo guifg=#efef8f guibg=NONE gui=underline
hi Todo ctermfg=228 ctermbg=NONE cterm=underline

hi Type term=underline
hi Type ctermfg=LightGreen
hi Type guifg=#60ff60 gui=bold

hi WildMenu ctermfg=196 ctermbg=NONE cterm=bold,underline
hi WildMenu guifg=#ee1111 guibg=#000000 gui=bold,underline

hi SignColumn cterm=NONE ctermbg=NONE ctermfg=White
hi SignColumn guibg=#000000

" match parentheses, brackets
hi MatchParen ctermfg=Green ctermbg=NONE cterm=NONE
hi MatchParen guifg=#00ff00 guibg=NONE gui=NONE

" Common groups that link to default highlighting.
hi link String         Constant
hi link Character      Constant
hi link Number         Constant
hi link Boolean        Constant
hi link Float          Number
hi link Conditional    Repeat
hi link Label          Statement
hi link Keyword        Statement
hi link Exception      Statement
hi link Include        PreProc
hi link Define         PreProc
hi link Macro          PreProc
hi link PreCondit      PreProc
hi link StorageClass   Type
hi link Structure      Type
hi link Typedef        Type
hi link Tag            Special
hi link SpecialChar    Special
hi link Delimiter      Special
hi link SpecialComment Special
hi link Debug          Special
