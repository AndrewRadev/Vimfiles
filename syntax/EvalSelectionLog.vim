" EvalSelectionLog.vim
" @Author:      Thomas Link (mailto:samul@web.de?subject=vim-EvalSelectionLog)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     16-Feb-2005.
" @Last Change: 16-Feb-2005.
" @Revision:    0.12

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

setlocal commentstring=\|\|\ %s

syn match evalSelectionLoggedCommand /^||.*$/

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_evalSel_syntax_inits")
  if version < 508
    let did_evalSel_syntax_inits = 1
    command! -nargs=+ HiLink hi link <args>
  else
    command! -nargs=+ HiLink hi def link <args>
  endif
 
  HiLink evalSelectionLoggedCommand Comment

  delcommand HiLink
endif

