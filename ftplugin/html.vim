set expandtab

" Guard against embedded stuff:
if &ft == 'html'
  command! -buffer Run Utl openLink currentFile
endif
