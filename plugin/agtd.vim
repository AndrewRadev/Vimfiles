" ------------------------------------------------------------------------------
" File:		plugin/agtd.vim - Almighty GTD File
"
" Author:	    Francisco Garcia Rodriguez <contact@francisco-garcia.net>
"
" Licence:	This program is free software; you can redistribute it and/or
"		modify it under the terms of the GNU General Public License.
"		See http://www.gnu.org/copyleft/gpl.txt
"		This program is distributed in the hope that it will be
"		useful, but WITHOUT ANY WARRANTY; without even the implied
"		warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
"
" Version:	0.2 Alpha
"
" Files:	
"		doc/agtd.vim
"		plugin/agtd.vim
"		syntax/agtd.vim
"		ftplugin/agtd.vim
"
" History:
"   0.2  Bug fixing and clutter clean-up
"           Calendar displays colors
"           Variable naming matches better plug-in name
"           Task insertions works when there is an http:// address
"           Common environment values pushed into a ftplugin
"           UTL Schema prototype for ssh links
"   0.1  Initial version
" ------------------------------------------------------------------------------

if exists("loaded_agtd") 
    finish
endif
let loaded_agtd = "0.1"

let s:agtd_dateRegx    = '\u::\d\d-\d\d\(-\d\d\)\?'
let s:agtd_ProjectRegx = '^\s\+\u\+'


" Move task at TOP
"
" Get current task line (usually within a PROJECT section) and move it to the
" top of the buffer, where the current todo tasks should be. It will also try
" to append a project label. As an example, when the cursor is on this line:
"
"       @net Find person
"
" It will be moved to the 2nd line of the buffer as:
" (1st should be the section title)
"
"       @net p:task:subtask Find person
"
function Gtd_insertTask()
    let task_line_no = line ('.')
    let line         = getline (task_line_no)
    let task         = matchstr (line,' \w.*$')
    let context      = matchstr (line,'@\w\+')
    if context == ""
        let v:errmsg = "Line has not a context label ..@.."
        echohl ErrorMsg | echo v:errmsg | echohl None
        return
    endif

    " Get project label as in p:pro:sub1:sub2
    if match (line,' p:\w*') == -1
        " Line has no label 
        let lastCol = 0
        let project = ""
        let col = 0
        while col != 4
            " Last project name is in column 4

            " Get project name looking backwards
            let pos = search(s:agtd_ProjectRegx, 'b', 1)
            if pos == 0
                let v:errmsg = "Could not build project name"
                echohl ErrorMsg | echo v:errmsg | echohl None
                return
            endif

            " Project name found: go to get line and colum
            call cursor (pos)
            let line = getline (pos)
            let col = match(line,'\u\+')

            if col != lastCol 
                " Project names in the same column are siblings, not an ancestor
                let project = ":" . tolower(matchstr(line,'\u\+')) . project
                let lastCol = col
            endif
        endwhile
        let entry = "    ".context." p".project.task
    else
        let entry = "    ".context." ".task
    endif

    " Insert new project line
    call append(1, entry)
    call cursor (task_line_no + 1,0)
    normal dd
    echo "New task added: " . entry
endfunction


" Go to PROJECT line
"
" Parse the current line to find a p:project label and decompose it to find
" the rest of the tasks related with such project. 
"
" If there are different subprojects (p:xxx:yy:z) the function will actually
" start jumping step by step, deeper into the hierarchy until the end or the
" first failed search
function Gtd_getProject()
    let line = getline ('.')
    let label = matchstr(line, 'p:\S\+')
    let path = split (label, ':')

    " Find project first line
    for i in path[1:]
        let project = toupper(i)
        call cursor ( search('^\s\+'.project) )
        normal zo
    endfor
    let projectPos = getpos ('.')

    " Get tasks for same project (TODO later)
    "echo "Tasks for project ".label
    normal gg
    let pos = search(label, 'W')
    let listLines = []
    while pos != 0
        let line = getline ('.')
        call add (listLines, line)
        let pos = search(label, 'W')
    endwhile

    " Return to project first line
    call setpos ('.', projectPos)
    normal zt
    normal jzo
    " echo listLines
endfunction


" FoldLevel for TODO files
"
" Indent based level. The diference from fdm=indent is that two line breaks
" are needed to break the fold
function Gtd_foldLevel(pos)
    let line = getline (a:pos)
    let col = match (line,'\S')
    if col == -1
        " Empty lines assume same level as the previous one
        " ... except if the next one is a lower indentation
        let line = getline (a:pos - 1)
        let col_up = match (line,'\S')

        let line = getline (a:pos - 1)
        let col_down = match (line,'\S')
        if col_up > col_down
            let col = col_up;
        endif
    endif
    let level = col / 4
    return level
endfunction


" Search the file for mark tags and set them
"
" Starting from the beggining of the file, search for auto-mark labels and set
" them as a new mark
function Gtd_setMarks()
    call cursor (1)
    let pos = search('m::\l', 'W')
    while pos != 0
        let line = getline ('.')
        let mark = matchstr (line, 'm::\l')
        let mark = strpart (mark, 3, 1)
        exe "mark " mark

        let pos = search('m::\l', 'W')
    endwhile
    normal gg
endfunction


" Search project
"
" Locate first appearence of project name, jump to it and unfold
function Gtd_searchProject(pro)
    let line_no = search ('^\s\+'.a:pro) 
    call cursor (line_no) 
    exe line_no."foldopen"
    exe line_no."foldopen"
    exe line_no."foldopen"
    exe line_no."foldopen"
    normal ztl
    exe line_no+1."foldopen"
endfunction


" List of projects 
"
" Custom function for auto-completion. Auto-complete with project names within
" current buffer.
function Gtd_getProjectList(ArgLead, CmdLine, CursorPos)
    let proList = []
    let proName = '^\s\+'.a:ArgLead.'\u\+'
    let startPos = getpos ('.')
    call cursor (1,1)
    let pos = search(proName) 
    while pos != 0
        call cursor (pos)
        let line = getline (pos)
        let pro = matchstr (line,'\u\+')
        echo pro
        if index(proList, pro) == -1
            call add(proList, pro)
        endif

        let pos = search(proName, 'W') 
    endwhile
    call setpos ('.', startPos)
    return proList
endfunction


" Collect lines with a date mark on it
function s:Gtd_getDateLines()
    let startPos = getpos ('.')
    let datesList = []
    call cursor (1,1)

    " Search tasks with dates
    let pos = search(s:agtd_dateRegx) 
    while pos != 0
        call cursor (pos)
        let line = getline ('.')
        let date = matchstr (line,s:agtd_dateRegx)
        let date = strpart (date, 3)
        if strlen (date) == 5
            let date = strftime("%Y")."-".date
        endif

        " Remove indentation
        let line = substitute (line, '^\s\+', "", "")
        let line = date."    ".line
        call add (datesList, line)
        let pos = search(s:agtd_dateRegx, 'W') 
    endwhile
    call setpos ('.', startPos)
    return datesList
endfunction


" Create a buffer with all marked the marked events
function Gtd_displayCalendar()
    let datesList = s:Gtd_getDateLines()

    " Make that temporal buffer
    let tmpBuffer = "tmpGtdCalendarDisp.tmp"
    let gtdBuffer = bufnr ('')
    silent! exe 'edit '. tmpBuffer
    set buftype=nofile
    set bufhidden=hide
    set noswf
    set nobuflisted
    set filetype=agtd
    set fdm=indent
    set foldminlines=0

    " Display sorted list of dates and grouped by months
    let thisMonth = "XX"
    for line in sort (datesList)
        " Remove date and following empty spaces
        let line = substitute (line, s:agtd_dateRegx.'\s*', "", "")

        " Insert month if different from the previous one
        let month = matchstr(line, '-\d\d-')
        if match (month, thisMonth) == -1
            let thisMonth = month
            call append ('$', "")
            call append ('$', month)
        endif

        call append ('$', "\t".line)
    endfor

    " Remove two empty lines from the beginning and open all folds
    normal gg2ddzR
    set ro
endfunction


" Build an iCalendar file 
"
" Search in the current buffer all timestamps and build an iCalendarfile
" according RFC-5545. All the comments will be plain events, since the current
" notation will not recognize time-frames.
" 
" NOTES:
"   * The generated UID is random. If you generate and import the output
"   several times, you will get the same event repeated in your calendar
"   program because it cannot identify updated components TODO
function Gtd_buildICalFile()
    let datesList = s:Gtd_getDateLines()
    let uid = 0

    " File header
    echo "BEGIN:VCALENDAR"
    echo "PRODID:-//DIGITAL-LUMBERJACK/AGTD Vim Calendar File 0.1//EN"
    echo "VERSION:2.0"
    
    for line in sort (datesList)
        let stamp = substitute(line, "-", "", "g")
        let stamp = matchstr(line, "\d\{8}")
        let summary = strpart (line, 13)
        echo "BEGIN:VEVENT"
        echo "DTSTAMP:".stamp."T000000Z"
        echo "UID:".uid."@agtd-vim"
        echo "SUMMARY:".summary

        let uid = uid + 1
    endfor
    echo "END:VCALENDAR"
endfunction

" Utl SSH Scheme
fu! Utl_AddressScheme_ssh(auri, fragment, dispMode)
    let add = split(a:auri,':')[-1]
    echo add
    exe "!sh -c \"ssh ".add."\""
    return []
endf

" Almighty GTD Vim script commands
command -nargs=1 -complete=customlist,Gtd_getProjectList GSearch call Gtd_searchProject("<args>")
command GCalendar call Gtd_displayCalendar()
command GInsert call Gtd_insertTask()
command GGo call Gtd_getProject() 
"command Gsort .sort /\s\{8}/

finish

