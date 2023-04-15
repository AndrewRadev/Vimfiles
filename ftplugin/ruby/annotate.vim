" Evaluate and annotate the buffer through rcodetools
command! -buffer Annotate call lib#InPlace('%!xmpfilter --no-warnings')

" Auto-evaluate on save
command! -buffer AutoAnnotate autocmd BufWritePre <buffer> Annotate
