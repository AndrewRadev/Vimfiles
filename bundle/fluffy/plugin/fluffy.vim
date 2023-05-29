if exists('g:loaded_fluffy') || &cp
  finish
endif

let g:loaded_fluffy = '0.0.1' " version number
let s:keepcpo = &cpo
set cpo&vim

if !exists('g:fluffy_matchseq')
  let g:fluffy_matchseq = 1
endif

if !exists('g:fluffy_show_score')
  let g:fluffy_show_score = 0
endif

hi def link fluffyMatch Search
hi def link fluffyScore TODO

command! Fluffy call fluffy#Run('<mods>')

let &cpo = s:keepcpo
unlet s:keepcpo
