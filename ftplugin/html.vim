set expandtab

" Guard against embedded stuff:
if &ft == 'html'
  RunCommand Open %
endif
