" Simpler tag searches:
command! -nargs=1 Function TTags f <args>
command! -nargs=1 Class    TTags c <args>

" Clear up garbage:
command! CleanGarbage %s/\s\{-}$//g
