RunCommand !R CMD BATCH %:S

ConsoleCommand call r#StartConsole(expand('%'))

nnoremap gm :call Open('https://rdocumentation.org/search?q='..expand('<cword>'))<cr>
