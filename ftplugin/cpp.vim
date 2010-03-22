setlocal tags+=~/tags/stl.tags

command! -buffer -nargs=* Run !./a.out <args>

iabbr null NULL
