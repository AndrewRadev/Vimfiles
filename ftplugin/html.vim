set expandtab

command! -buffer -range=% Reformat <line1>,<line2>!tidy -q -i

" Guard against embedded stuff:
if &ft == 'html'
  RunCommand Open %
endif
