" Name:             andrew-light
" Description:      A fork of "morning" with some customizations
" Original Website: https://github.com/vim/colorschemes

set background=light

hi clear
let g:colors_name = 'andrew-light'

let s:t_Co = exists('&t_Co') && !has('gui_running') ? (&t_Co ?? 0) : -1

if (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = ['#e4e4e4', '#a52a2a', '#ff00ff', '#6a0dad', '#008787', '#2e8b57', '#6a5acd', '#bcbcbc', '#0000ff', '#a52a2a', '#ff00ff', '#6a0dad', '#008787', '#2e8b57', '#6a5acd', '#000000']
endif
hi! link Terminal Normal
hi! link LineNrAbove LineNr
hi! link LineNrBelow LineNr
hi! link CurSearch Search
hi! link CursorLineFold CursorLine
hi! link CursorLineSign CursorLine
hi! link StatuslineTerm Statusline
hi! link StatuslineTermNC StatuslineNC
hi! link MessageWindow Pmenu
hi! link PopupNotification Pmenu
hi Normal guifg=#000000 guibg=#e4e4e4 gui=NONE cterm=NONE
hi EndOfBuffer guifg=#0000ff guibg=#e4e4e4 gui=bold cterm=bold
hi Folded guifg=#00008b guibg=#d3d3d3 gui=NONE cterm=NONE
hi CursorLine guifg=NONE guibg=#d3d3d3 gui=NONE cterm=NONE
hi CursorColumn guifg=NONE guibg=#d3d3d3 gui=NONE cterm=NONE
hi CursorLineNr guifg=#a52a2a guibg=NONE gui=bold cterm=bold
hi QuickFixLine guifg=#000000 guibg=#ffff00 gui=NONE cterm=NONE
hi StatusLine guifg=Black   guibg=NONE   gui=bold
hi StatusLineNC guifg=Black   guibg=NONE gui=NONE
hi VertSplit gui=NONE   guifg=Black
hi Pmenu guifg=#000000 guibg=#b2b2b2 gui=NONE cterm=NONE
hi PmenuSel guifg=#000000 guibg=#ffff00 gui=NONE cterm=NONE
hi PmenuSbar guifg=NONE guibg=#e4e4e4 gui=NONE cterm=NONE
hi PmenuThumb guifg=NONE guibg=#000000 gui=NONE cterm=NONE
hi TabLine guifg=#000000 guibg=#bcbcbc gui=underline cterm=underline
hi TabLineFill guifg=NONE guibg=NONE gui=reverse ctermfg=NONE ctermbg=NONE cterm=reverse
hi TabLineSel guifg=#000000 guibg=#e4e4e4 gui=bold cterm=bold
hi ToolbarLine guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi ToolbarButton guifg=NONE guibg=#bcbcbc gui=bold cterm=bold
hi NonText guifg=#0000ff guibg=#bcbcbc gui=bold cterm=bold
hi SpecialKey guifg=#bcbcbc guibg=NONE gui=NONE cterm=NONE
hi Visual guibg=#87afdf guifg=Black gui=NONE
hi VisualNOS guifg=NONE guibg=#0000ff gui=NONE cterm=NONE
hi LineNr guifg=#a52a2a guibg=NONE gui=NONE cterm=NONE
hi FoldColumn guifg=#00008b guibg=NONE gui=NONE cterm=NONE
hi SignColumn guifg=#00008b guibg=NONE gui=NONE cterm=NONE
hi Underlined guifg=#6a5acd guibg=NONE gui=underline cterm=underline
hi Error guifg=#ff0000 guibg=#e4e4e4 gui=reverse cterm=reverse
hi ErrorMsg guifg=#ff0000 guibg=#e4e4e4 gui=reverse cterm=reverse
hi WarningMsg guifg=#6a0dad guibg=NONE gui=bold cterm=bold
hi MoreMsg guifg=#2e8b57 guibg=NONE gui=bold cterm=bold
hi ModeMsg guifg=#000000 guibg=NONE gui=bold cterm=bold
hi Question guifg=#008787 guibg=NONE gui=bold cterm=bold
hi Todo guifg=#000000 guibg=#ffff00 gui=NONE cterm=NONE
hi MatchParen guifg=#e4e4e4 guibg=#6a5acd gui=NONE cterm=NONE
hi Search guifg=#e4e4e4 guibg=#6a0dad gui=NONE cterm=NONE
hi IncSearch guifg=#2e8b57 guibg=NONE gui=reverse cterm=reverse
hi WildMenu guifg=#000000 guibg=#ffff00 gui=bold cterm=bold
hi ColorColumn guifg=#000000 guibg=#ffffff gui=NONE cterm=NONE
hi Cursor guifg=#e4e4e4 guibg=#2e8b57 gui=NONE cterm=NONE
hi lCursor guifg=#e4e4e4 guibg=#a52a2a gui=NONE cterm=NONE
hi SpellBad guifg=#ff0000 guibg=NONE guisp=#ff0000 gui=undercurl cterm=underline
hi SpellCap guifg=#00d700 guibg=NONE guisp=#00d700 gui=undercurl cterm=underline
hi SpellLocal guifg=#a52a2a guibg=NONE guisp=#a52a2a gui=undercurl cterm=underline
hi SpellRare guifg=#2e8b57 guibg=NONE guisp=#2e8b57 gui=undercurl cterm=underline
hi Comment guifg=#0000ff guibg=NONE gui=NONE cterm=NONE
hi Constant guifg=#ff00ff guibg=#eeeeee gui=NONE cterm=NONE
hi Identifier guifg=#008787 guibg=NONE gui=NONE cterm=NONE
hi Statement guifg=#a52a2a guibg=NONE gui=bold cterm=bold
hi PreProc guifg=#6a0dad guibg=NONE gui=NONE cterm=NONE
hi Type guifg=#2e8b57 guibg=NONE gui=bold cterm=bold
hi Special guifg=#6a5acd guibg=NONE gui=NONE cterm=NONE
hi Ignore guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
hi Directory guifg=#008787 guibg=NONE gui=bold cterm=bold
hi Conceal guifg=#0000ff guibg=NONE gui=NONE cterm=NONE
hi Title guifg=#a52a2a guibg=NONE gui=bold cterm=bold
hi DiffAdd guifg=#ffffff guibg=#5f875f gui=NONE cterm=NONE
hi DiffChange guifg=#ffffff guibg=#5f87af gui=NONE cterm=NONE
hi DiffText guifg=#000000 guibg=#c6c6c6 gui=NONE cterm=NONE
hi DiffDelete guifg=#ffffff guibg=#af5faf gui=NONE cterm=NONE

if s:t_Co >= 256
  hi! link Terminal Normal
  hi! link LineNrAbove LineNr
  hi! link LineNrBelow LineNr
  hi! link CurSearch Search
  hi! link CursorLineFold CursorLine
  hi! link CursorLineSign CursorLine
  hi! link StatuslineTerm Statusline
  hi! link StatuslineTermNC StatuslineNC
  hi! link MessageWindow Pmenu
  hi! link PopupNotification Todo
  hi Normal ctermfg=16 ctermbg=254 cterm=NONE
  hi EndOfBuffer ctermfg=21 ctermbg=254 cterm=bold
  hi Folded ctermfg=18 ctermbg=252 cterm=NONE
  hi CursorLine ctermfg=NONE ctermbg=252 cterm=NONE
  hi CursorColumn ctermfg=NONE ctermbg=252 cterm=NONE
  hi CursorLineNr ctermfg=124 ctermbg=NONE cterm=bold
  hi QuickFixLine ctermfg=16 ctermbg=226 cterm=NONE
  hi StatusLine ctermfg=Black ctermbg=NONE cterm=bold
  hi StatusLineNC ctermfg=Black ctermbg=NONE  cterm=NONE
  hi VertSplit cterm=NONE ctermfg=Black
  hi Pmenu ctermfg=16 ctermbg=249 cterm=NONE
  hi PmenuSel ctermfg=16 ctermbg=226 cterm=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=254 cterm=NONE
  hi PmenuThumb ctermfg=NONE ctermbg=16 cterm=NONE
  hi TabLine ctermfg=16 ctermbg=250 cterm=underline
  hi TabLineFill ctermfg=NONE ctermbg=NONE cterm=reverse
  hi TabLineSel ctermfg=16 ctermbg=254 cterm=bold
  hi ToolbarLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi ToolbarButton ctermfg=NONE ctermbg=250 cterm=bold
  hi NonText ctermfg=21 ctermbg=250 cterm=bold
  hi SpecialKey ctermfg=250 ctermbg=NONE cterm=NONE
  hi Visual ctermbg=110   ctermfg=16
  hi VisualNOS ctermfg=NONE ctermbg=21 cterm=NONE
  hi LineNr ctermfg=124 ctermbg=NONE cterm=NONE
  hi FoldColumn ctermfg=18 ctermbg=NONE cterm=NONE
  hi SignColumn ctermfg=18 ctermbg=NONE cterm=NONE
  hi Underlined ctermfg=62 ctermbg=NONE cterm=underline
  hi Error ctermfg=196 ctermbg=254 cterm=reverse
  hi ErrorMsg ctermfg=196 ctermbg=254 cterm=reverse
  hi WarningMsg ctermfg=55 ctermbg=NONE cterm=bold
  hi MoreMsg ctermfg=29 ctermbg=NONE cterm=bold
  hi ModeMsg ctermfg=16 ctermbg=NONE cterm=bold
  hi Question ctermfg=30 ctermbg=NONE cterm=bold
  hi Todo ctermfg=16 ctermbg=226 cterm=NONE
  hi MatchParen ctermfg=254 ctermbg=62 cterm=NONE
  hi Search ctermfg=254 ctermbg=55 cterm=NONE
  hi IncSearch ctermfg=29 ctermbg=NONE cterm=reverse
  hi WildMenu ctermfg=196 ctermbg=NONE cterm=bold,underline
  hi ColorColumn ctermfg=16 ctermbg=231 cterm=NONE
  hi Cursor ctermfg=254 ctermbg=29 cterm=NONE
  hi lCursor ctermfg=254 ctermbg=124 cterm=NONE
  hi SpellBad ctermfg=196 ctermbg=NONE cterm=underline
  hi SpellCap ctermfg=40 ctermbg=NONE cterm=underline
  hi SpellLocal ctermfg=124 ctermbg=NONE cterm=underline
  hi SpellRare ctermfg=29 ctermbg=NONE cterm=underline
  hi Comment ctermfg=246 ctermbg=NONE cterm=NONE
  hi Constant ctermfg=28 ctermbg=NONE cterm=NONE
  hi Identifier ctermfg=20 ctermbg=NONE cterm=NONE
  hi Statement ctermfg=124 ctermbg=NONE cterm=bold
  hi PreProc ctermfg=55 ctermbg=NONE cterm=NONE
  hi Type ctermfg=29 ctermbg=NONE cterm=bold
  hi Special ctermfg=92 ctermbg=NONE cterm=NONE
  hi Ignore ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Directory ctermfg=30 ctermbg=NONE cterm=bold
  hi Conceal ctermfg=21 ctermbg=NONE cterm=NONE
  hi Title ctermfg=124 ctermbg=NONE cterm=bold
  hi DiffAdd ctermfg=231 ctermbg=65 cterm=NONE
  hi DiffChange ctermfg=231 ctermbg=67 cterm=NONE
  hi DiffText ctermfg=16 ctermbg=251 cterm=NONE
  hi DiffDelete ctermfg=231 ctermbg=133 cterm=NONE
  unlet s:t_Co
  finish
endif
