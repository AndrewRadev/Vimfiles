set background=dark
hi clear

if exists("syntax_on")
 syntax reset
endif

let g:colors_name = "andrew"

" Red cursor when using an alternative keymap
hi lCursor guibg=Red

" White normal text
hi Normal cterm=NONE ctermfg=White
hi Normal guifg=#dddddd guibg=Black

" Grayish comments
hi Comment ctermfg=248
hi Comment guifg=#777777

" Bluish constants: strings, numbers
hi Constant ctermfg=43
hi Constant guifg=#00dfaf

" Cyan function names
hi Function ctermfg=Cyan
hi Function guifg=Cyan

" Bluish identifiers
hi Identifier ctermfg=Cyan
hi Identifier guifg=#40ffff

" Red operators
hi Operator ctermfg=Red
hi Operator guifg=Red

" Greenish types
hi Type ctermfg=LightGreen
hi Type guifg=#60ff60 gui=bold

" Dark magenta special characters: some operators, regex modifiers
hi Special ctermfg=40
hi Special guifg=#00df00

" Yellow statements: ifs, defs
hi Statement cterm=NONE ctermfg=Yellow
hi Statement gui=NONE   guifg=Yellow

" Pure red errors
hi Error ctermbg=Red  ctermfg=White
hi Error guibg=Red    guifg=White

" Yellowish todos
hi Todo guifg=#efef8f guibg=NONE gui=underline
hi Todo ctermfg=228 ctermbg=NONE cterm=underline

" Just underline when using a cursorline
hi CursorLine cterm=underline ctermbg=NONE
hi CursorLine gui=underline   guibg=NONE

" Bluish directory names
hi Directory cterm=NONE ctermfg=45
hi Directory gui=NONE   guifg=#00dfff

" Light blue preprocessor directives
hi PreProc ctermfg=LightBlue cterm=NONE
hi PreProc guifg=LightBlue   gui=NONE

" Subtle gray diffs.
hi DiffAdd cterm=NONE ctermbg=235
hi DiffAdd gui=NONE   guibg=#262626

hi DiffChange cterm=NONE ctermbg=235
hi DiffChange gui=NONE   guibg=#262626

hi DiffDelete cterm=NONE ctermfg=238   ctermbg=244
hi DiffDelete gui=NONE   guifg=#444444 guibg=#808080

hi DiffText cterm=bold ctermfg=255   ctermbg=196
hi DiffText gui=bold   guifg=#ffffff

" Hide concealed items
hi Ignore ctermfg=Black
hi Ignore guifg=bg

" Dark gray popup menu with blue selection
hi Pmenu cterm=NONE ctermfg=255 ctermbg=235
hi Pmenu guibg=#262626 guifg=#ffffff

hi PmenuSbar cterm=NONE ctermfg=240 ctermbg=240
hi PmenuSbar guibg=#444444

hi PmenuSel cterm=NONE ctermfg=255 ctermbg=21
hi PmenuSel guibg=#0000ff guifg=#ffffff

hi PmenuThumb cterm=NONE ctermfg=255 ctermbg=255
hi PmenuThumb guifg=#ffffff

" Light blue visual selection
hi Visual ctermbg=110   ctermfg=16
hi Visual guibg=#87afdf guifg=Black gui=NONE

" Grayish search
hi Search ctermfg=16    ctermbg=248
hi Search guifg=#000000 guibg=#a8a8a8

" Slim separator lines
hi StatusLine ctermfg=White ctermbg=NONE cterm=bold
hi StatusLine guifg=White   guibg=NONE   gui=bold

hi StatusLineNC ctermfg=White ctermbg=NONE  cterm=NONE
hi StatusLineNC guifg=White   guibg=NONE gui=NONE

hi VertSplit cterm=NONE ctermfg=White
hi VertSplit gui=NONE   guifg=White

" Dark tabline, white text
hi TabLine cterm=NONE ctermfg=244   ctermbg=236
hi TabLine gui=NONE   guifg=#b6bf98 guibg=#363946

hi TabLineFill cterm=NONE ctermfg=187 ctermbg=236
hi TabLineFill gui=NONE guifg=#cfcfaf guibg=#363946

hi TabLineSel cterm=bold ctermfg=254   ctermbg=236
hi TabLineSel gui=bold   guifg=#efefef guibg=#414658

" Gray folds with blue text
hi Folded ctermfg=14 ctermbg=235 cterm=NONE
hi Folded guifg=#91d6f8 guibg=#363946 gui=NONE

hi FoldColumn ctermfg=14 ctermbg=235 cterm=NONE
hi FoldColumn guifg=#91d6f8 guibg=#363946 gui=NONE

" No background for wildmenu, selection is red, bold and underlined
hi WildMenu ctermfg=196 ctermbg=NONE cterm=bold,underline
hi WildMenu guifg=#ee1111 guibg=#000000 gui=bold,underline

" Nothing special for sign column
hi SignColumn cterm=NONE ctermbg=NONE ctermfg=White
hi SignColumn guibg=#000000

" Gray line numbers
hi LineNr ctermfg=102   ctermbg=NONE
hi LineNr guifg=#818698 guibg=NONE

" Yellow bracket matches
hi MatchParen ctermfg=Yellow ctermbg=NONE cterm=bold
hi MatchParen guifg=Yellow   guibg=NONE   gui=bold

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
