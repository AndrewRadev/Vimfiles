" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Maintainer:   Ron Aaron <ron@ronware.org>
" Last Change:  2003 May 02

set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "elflord-custom"

hi Comment      term=bold      ctermfg=DarkCyan    guifg=#80a0ff gui=italic
hi Constant     term=underline ctermfg=Magenta     guifg=Magenta
hi CursorLine   cterm=none     ctermbg=16          guibg=#101010
hi DiffAdd      cterm=none     ctermbg=235         guibg=#262626
hi DiffChange   cterm=none     ctermbg=235         guibg=#262626
hi DiffDelete   cterm=none     ctermfg=238         ctermbg=244   guibg=#808080 guifg=#444444
hi DiffText     cterm=bold     ctermfg=255         ctermbg=196   guifg=#ffffff
hi Directory    cterm=none     ctermfg=Green       guifg=Green
hi Error        term=reverse   ctermbg=Red         ctermfg=White guibg=Red     guifg=White
hi Folded       cterm=none     ctermfg=16          ctermbg=110   guifg=#000000 guibg=#87afd7
hi Function     term=bold      ctermfg=White       guifg=White
hi Identifier   term=underline cterm=bold          ctermfg=Cyan  guifg=#40ffff
hi Ignore       ctermfg=black  guifg=bg
hi Normal       cterm=none     guifg=cyan          guibg=black
hi Operator     ctermfg=Red    guifg=Red
hi Pmenu        cterm=none     ctermfg=255         ctermbg=235   guibg=#262626 guifg=#ffffff
hi PmenuSbar    cterm=none     ctermfg=240         ctermbg=240   guibg=#444444
hi PmenuSel     cterm=none     ctermfg=255         ctermbg=21    guibg=#0000ff guifg=#ffffff
hi PmenuThumb   cterm=none     ctermfg=255         ctermbg=255   guifg=#ffffff
hi PreProc      term=underline ctermfg=LightBlue   guifg=#ff80ff
hi Repeat       term=underline ctermfg=White       guifg=white
hi Special      term=bold      ctermfg=DarkMagenta guifg=Red
hi Statement    term=bold      ctermfg=Yellow      gui=bold      guifg=#aa4444
hi StatusLine   cterm=bold     ctermfg=16          ctermbg=111   guibg=#000000 guifg=#87afd7
hi StatusLineNC cterm=none     ctermfg=16          ctermbg=109   guibg=#000000 guifg=#87afd7
hi Todo         term=standout  ctermbg=Yellow      ctermfg=Black guifg=Blue    guibg=Yellow
hi Type         term=underline ctermfg=LightGreen  guifg=#60ff60 gui=bold
hi VertSplit    cterm=none     ctermfg=254         guifg=#ffffff gui=none
hi WildMenu     cterm=none     ctermfg=16          ctermbg=11
hi SignColumn   cterm=none     ctermbg=none        guibg=#000000

hi NonText cterm=NONE ctermfg=NONE

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
