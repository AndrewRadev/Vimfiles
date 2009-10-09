" File: vimmpc.vim
" About: Wrapper around basic MPD functionality
" Author: Gavin Gilmour (gavin (at) brokentrain dot net)
" Last Modified: April 10, 2007
" Prerequisites: mpdclient2
" Installation: Map :MPC to something
" Version: 20070410
"
" TODO:
"   * Playlist editing
"   * Other commands (update, random, seek, repeat, etc.)
"   * Progressive statusbar?
"   * Database view
"   * Fancy playlist colour scheme
"   * Alternative views for playlist, folding at albums etc.
"   * Mini-queues and stuff?
"   * History list?
"   * Fancier search features
"   * Song-info windows
"       * Open the file like an archive with some tool?
"       * Tag editing?
"   * Make the visual selection = progress?
"   * Oh, oh! Fancy database searching with :cnext & :cprev?
"
" ChangeLog:
"   10-04-07: Playlist auto-focus support.
"   27-02-07: Fixes lyrics issues, implemented remote functionality!
"   19-01-07: Lyrics window, experimental playlist folding.
"   21-12-06: Total rewrite using vim's python support.
"   05-11-06: Initial version.

if !has("python")
    echomsg 'vimpc.vim: Error! Python support is not available, ' .
                \ 'plugin not loaded.'
    finish
endif

function TrackFoldText()
    let line = getline(v:foldstart)
    let tracks = v:foldend - v:foldstart - 1
    let tracks = printf("%2d", tracks)
    let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
    return '+-' . v:folddashes . ' ' . tracks . ' tracks:' . sub
endfunction

function DatabaseFoldText()
    let line = getline(v:foldstart)
    let tracks = v:foldend - v:foldstart - 1
    let tracks = printf("%2d", tracks)
    let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
    return sub
endfunction

if !exists('g:loaded_mpc')
    pyfile <sfile>:p:h/vimmpc.py
    command! -nargs=0 MPC python MPC_init("Playlist")
    let g:loaded_mpc = 1
    finish
endif
