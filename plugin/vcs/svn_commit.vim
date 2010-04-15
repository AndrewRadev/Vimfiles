" SVN aborted commit log reader
" Reads in the newest svn-commit.tmp log in the current directory
" (these get left behind by aborted commits)
"
" Written by Chris AtLee <chris@atlee.ca>
" Released under the GPLv2
" Version 0.2

function s:ReadPrevCommitLog()
    " Get the newest file (ignoring this one)
    let commitfile = system("ls -t svn-commit*.tmp | grep -v " . bufname("%") . " | head -1")
    " Strip off trailing newline
    let commitfile = substitute(commitfile, "\\s*\\n$", "", "")
    " If we're left with a file that actually exists, then we can read it in
    if filereadable(commitfile)
        " Read in the old commit message
        "echo "Reading " . commitfile
        silent exe "0read " . commitfile

        " Delete everything from the first "^--This line" to the last one
        normal 1G
        let first = search("^--This line", "")
        normal G$
        let last = search("^--This line", "b") - 1

        if last > first
            silent exe first . "," . last . "d"
        endif
        normal 1G
        set modified
    endif
endf
call s:ReadPrevCommitLog()
