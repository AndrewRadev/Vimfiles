" dir.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-06-30.
" @Last Change: 2009-02-15.
" @Revision:    0.0.29

if &cp || exists("loaded_tlib_dir_autoload")
    finish
endif
let loaded_tlib_dir_autoload = 1

let s:dir_stack = []

" EXAMPLES: >
"   tlib#dir#CanonicName('foo/bar')
"   => 'foo/bar/'
function! tlib#dir#CanonicName(dirname) "{{{3
    if a:dirname !~ '[/\\]$'
        return a:dirname . g:tlib_filename_sep
    endif
    return a:dirname
endf


" EXAMPLES: >
"   tlib#dir#PlainName('foo/bar/')
"   => 'foo/bar'
function! tlib#dir#PlainName(dirname) "{{{3
    let dirname = a:dirname
    while dirname[-1 : -1] == g:tlib_filename_sep
        let dirname = dirname[0 : -2]
    endwh
    return dirname
    " return substitute(a:dirname, tlib#rx#Escape(g:tlib_filename_sep).'\+$', '', '')
endf


" Create a directory if it doesn't already exist.
function! tlib#dir#Ensure(dir) "{{{3
    if !isdirectory(a:dir)
        let dir = tlib#dir#PlainName(a:dir)
        return mkdir(dir, 'p')
    endif
    return 1
endf


" Return the first directory in &rtp.
function! tlib#dir#MyRuntime() "{{{3
    return get(split(&rtp, ','), 0)
endf


" :def: function! tlib#dir#CD(dir, ?locally=0) => CWD
function! tlib#dir#CD(dir, ...) "{{{3
    TVarArg ['locally', 0]
    let cmd = locally ? 'lcd ' : 'cd '
    " let cwd = getcwd()
    let cmd .= tlib#arg#Ex(a:dir)
    " TLogVAR cmd
    exec cmd
    " return cwd
    return getcwd()
endf


" :def: function! tlib#dir#Push(dir, ?locally=0) => CWD
function! tlib#dir#Push(dir, ...) "{{{3
    TVarArg ['locally', 0]
    call add(s:dir_stack, [getcwd(), locally])
    return tlib#dir#CD(a:dir, locally)
endf


" :def: function! tlib#dir#Pop() => CWD
function! tlib#dir#Pop() "{{{3
    let [dir, locally] = remove(s:dir_stack, -1)
    return tlib#dir#CD(dir, locally)
endf


