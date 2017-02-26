" Evaluate and annotate the buffer through rcodetools
command! Annotate call lib#InPlace('%!xmpfilter --no-warnings')

" Auto-evaluate on save
command! AutoAnnotate autocmd BufWritePre <buffer> Annotate
