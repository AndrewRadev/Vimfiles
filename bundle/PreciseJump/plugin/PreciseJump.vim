"
" PreciseJump - script to ease on-screen motion
" version: 0.49 - 2011-03-26
"
" author: Bartlomiej Podolak <bartlomiej (a) gmail com>
"

if exists('g:PreciseJump_loaded') || &cp || version < 702
    finish
endif

let g:PreciseJump_loaded = 1

"{{{xxxxxxxx   CONFIGURATION   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

if !exists('g:PreciseJump_target_keys')
    let g:PreciseJump_target_keys  = ''
    let g:PreciseJump_target_keys .= 'abcdefghijklmnopqrstuwxz'
    let g:PreciseJump_target_keys .= '123456789'
    let g:PreciseJump_target_keys .= "[];'\,./"
    let g:PreciseJump_target_keys .= 'ABCDEFGHIJKLMNOPQRSTUWXZ'
    let g:PreciseJump_target_keys .= '{}:"|<>?'
    let g:PreciseJump_target_keys .= '!@#$%^&*()_+'
endif


hi PreciseJumpTarget   ctermfg=yellow ctermbg=red cterm=bold gui=bold guibg=Red guifg=yellow

if !exists('g:PreciseJump_match_target_hi')
    let g:PreciseJump_match_target_hi = 'PreciseJumpTarget'
endif

nmap _F :call PreciseJumpF(0, 0, 0)<cr>
vmap _F <ESC>:call PreciseJumpF(0, 0, 1)<cr>
omap _F :call PreciseJumpF(0, 0, 0)<cr>

nmap _f :call PreciseJumpF(-1, -1, 0)<cr>
vmap _f <ESC>:call PreciseJumpF(-1, -1, 1)<cr>
omap _f :call PreciseJumpF(-1, -1, 0)<cr>

"nmap _t :call PreciseJumpT(-1, -1, 0)<cr>
"vmap _t <ESC>:call PreciseJumpT(-1, -1, 1)<cr>
"omap _t :call PreciseJumpT(-1, -1, 0)<cr>
"
"nmap _w :call PreciseJumpW(-1, -1, 0)<cr>
"vmap _w <ESC>:call PreciseJumpW(-1, -1, 1)<cr>
"omap _w :call PreciseJumpW(-1, -1, 0)<cr>
"
"nmap _e :call PreciseJumpE(-1, -1, 0)<cr>
"vmap _e <ESC>:call PreciseJumpE(-1, -1, 1)<cr>
"omap _e :call PreciseJumpE(-1, -1, 0)<cr>

if exists('g:PreciseJump_I_am_brave')
    nmap F :call PreciseJumpF(0, 0, 0)<cr>
    vmap F <ESC>:call PreciseJumpF(0, 0, 1)<cr>
    omap F v:call PreciseJumpF(0, 0, 0)<cr>

    nmap f :call PreciseJumpF(-1, -1, 0)<cr>
    vmap f <ESC>:call PreciseJumpF(-1, -1, 1)<cr>
    omap f v:call PreciseJumpF(-1, -1, 0)<cr>

    nmap t :call PreciseJumpT(-1, -1, 0)<cr>
    vmap t <ESC>:call PreciseJumpT(-1, -1, 1)<cr>
    omap t v:call PreciseJumpT(-1, -1, 0)<cr>
endif

"
"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"}}}
"{{{ initialization stuff
let s:index_to_key = split(g:PreciseJump_target_keys, '\zs')
let s:key_to_index = {}

let index = 0
for i in s:index_to_key
    let s:key_to_index[i] = index
    let index += 1
endfor
"}}}

"{{{ motion functions
function! PreciseJumpW(lines_prev, lines_next, vismode)
    call PreciseJump('\<.', a:lines_prev, a:lines_next, a:vismode)
endfunction

function! PreciseJumpE(lines_prev, lines_next, vismode)
    call PreciseJump('.\>', a:lines_prev, a:lines_next, a:vismode)
endfunction

function! PreciseJumpF(lines_prev, lines_next, vismode)
    let re = nr2char( getchar() )
    let re = escape(re, '.$^~')
    redraw
    call PreciseJump('\C'.re, a:lines_prev, a:lines_next, a:vismode)
endfunction

function! PreciseJumpT(lines_prev, lines_next, vismode)
    let re = escape( nr2char(getchar()), '.$^~')
    let re = '.' . re
    redraw
    call PreciseJump('\C'.re, a:lines_prev, a:lines_next, a:vismode)
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
" jump to l-th line and c-th column
"{{{ function! s:JumpToCoords(l, c, vismode)
function! s:JumpToCoords(l, c, vismode)
    let ve = &virtualedit
    setl virtualedit=""
    if a:vismode
        execute "normal! gv"
    endif
    execute "normal! " . a:l . "gg"
    normal! "0|"
    if a:c > 1
        execute "normal! " . (a:c - 1) . "l"
    endif
    execute "silent setl virtualedit=" . ve
    echo "Jumping to [" . a:l . ", " . a:c . "]"
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
" function returns list of places ([line, column]),
" that match regular expression 're'
" in lines of numbers from list 'line_numbers'
"{{{ function! s:FindTargets(re, line_numbers)
function! s:FindTargets(re, line_numbers)
    let targets = []
    for l in a:line_numbers
        let n = 1
        let match_start = match(getline(l), a:re, 0, 1)
        while match_start != -1
            call add(targets, [l, match_start + 1])
            let n += 1
            let match_start = match(getline(l), a:re, 0, n)
        endwhile
    endfor
    return targets
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
" split 'list' into groups (list of lists) of
" 'group_size' length
"{{{ function! s:SplitListIntoGroups(list, group_size)
function! s:SplitListIntoGroups(list, group_size)
    let groups = []
    let i = 0
    while i < len(a:list)
        call add(groups, a:list[i : i + a:group_size - 1])
        let i += a:group_size
    endwhile
    return groups
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! s:GetLinesFromCoordList(list)
function! s:GetLinesFromCoordList(list)
    let lines_seen = {}
    let lines_no = []
    for [l, c] in a:list
        if !has_key(lines_seen, l)
            call add(lines_no, l)
            let lines_seen[l] = 1
        endif
    endfor
    return lines_no
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! s:CreateHighlightRegex(coords)
function! s:CreateHighlightRegex(coords)
    let tmp = []
    for [l, c] in s:Flatten(a:coords)
        call add(tmp, '\%' . l . 'l\%' . c . 'c')
    endfor
    return join(tmp, '\|')
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! s:Flatten(list)
function! s:Flatten(list)
    let res = []
    for elem in a:list
        call extend(res, elem)
    endfor
    return res
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
" get a list of coordinates groups [   [ [1,2], [2,5] ], [ [2,2] ]  ]
" get a list of coordinates groups [   [ [1,2], [2,5] ]  ]
"{{{ function! s:AskForTarget(group)
function! s:AskForTarget(groups) abort
    let single_group = ( len(a:groups) == 1 ? 1 : 0 )

    " how many targets there is
    let targets_count = single_group ? len(a:groups[0]) : len(a:groups)

    if single_group && targets_count == 1
        return a:groups[0][0]
    endif

    " which lines need to be changed
    let lines = s:GetLinesFromCoordList(s:Flatten(a:groups))

    " creating copy of lines to be changed
    let lines_with_markers = {}
    for l in lines
        let lines_with_markers[l] = split(getline(l), '\zs')
    endfor

   " adding markers to lines
    let gr = 0 " group no
    for group in a:groups
        let el = 0 " element in group no
        for [l, c] in group
            " highlighting with group mark or target mark
            let lines_with_markers[l][c - 1] = s:index_to_key[ single_group ? el : gr ]
            let el += 1
        endfor
        let gr += 1
    endfor

   " create highlight
    let hi_regex = s:CreateHighlightRegex(a:groups)

    "
    let user_char = ''
    let modifiable = &modifiable
    let readonly = &readonly

    try
        let match_id = matchadd(g:PreciseJump_match_target_hi, hi_regex, -1)
        if modifiable == 0
            silent setl modifiable
        endif
        if readonly == 1
            silent setl noreadonly
        endif

        for [lnum, line_arr] in items(lines_with_markers)
            call setline(lnum, join(line_arr, ''))
        endfor
        redraw
        if single_group
            echo "target char>"
        else
            echo "group char>"
        endif
        let user_char = nr2char( getchar() )
        redraw
    finally
        normal! u
        normal 

        call matchdelete(match_id)
        redraw
        if modifiable == 0
            silent setl nomodifiable
        endif
        if readonly == 1
            silent setl readonly
        endif

        if ! has_key(s:key_to_index, user_char) || s:key_to_index[user_char] >= targets_count
            return []
        else
            if single_group
                if ! has_key(s:key_to_index, user_char)
                    return []
                else
                    return a:groups[0][ s:key_to_index[user_char] ]  " returning coordinates
                endif
            else
                return s:AskForTarget( [ a:groups[ s:key_to_index[user_char] ] ] )
            endif
        endif
    endtry
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! s:LinesAllSequential()
function! s:LinesAllSequential()
    return filter( range(line('w0'), line('w$')), 'foldclosed(v:val) == -1' )
endfunction
" }}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! s:LinesSurrondingAll(a:surrounding_lines)
function! s:LinesSurrondingAll(surrounding_lines)
    let cur_line = line('.')
    let line_numbers = [ cur_line ]
    let i = 1
    while 1
        let leave = 1
        if cur_line - i >= line('w0')
            call add(line_numbers, cur_line - i)
            let leave = 0
        endif

        if cur_line + i <= line('w$')
            call add(line_numbers, cur_line + i)
            let leave = 0
        endif

        if leave
            break
        endif
        let i += 1
    endwhile
    return line_numbers
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! s:LinesInRange(lines_prev, lines_next)
function! s:LinesInRange(lines_prev, lines_next)
    let all_lines = filter( range(line('w0'), line('w$')), 'foldclosed(v:val) == -1' )
    let current = index(all_lines, line('.'))

    let lines_prev = a:lines_prev == -1 ? current : a:lines_prev
    let lines_next = a:lines_next == -1 ? len(all_lines) : a:lines_next

    let lines_prev_i   = max( [0, current - lines_prev] )
    let lines_next_i   = min( [len(all_lines), current + lines_next] )

    return all_lines[ lines_prev_i : lines_next_i ]
endfunction
"}}}

"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
"{{{ function! PreciseJump()
function! PreciseJump(re, lines_prev, lines_next, vismode)
    let group_size = len(s:index_to_key)
    let lnums = s:LinesInRange(a:lines_prev, a:lines_next)

    let targets = s:FindTargets(a:re, lnums)
    if len(targets) == 0
        echo "No targets found"
        return
    endif

    let groups = s:SplitListIntoGroups( targets, group_size )

    " too many targets; showing only first ones
    if len(groups) > group_size
        echo "Showing only first targets"
        let groups = groups[0 : group_size - 1]
    endif

    let coords = s:AskForTarget(groups)

    if len(coords) != 2
        echo "Cancelled"
        return
    else
        call s:JumpToCoords(coords[0], coords[1], a:vismode)
    endif
endfunction
"}}}

finish

