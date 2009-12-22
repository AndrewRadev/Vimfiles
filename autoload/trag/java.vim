" java.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-12-01.
" @Last Change: 2009-02-27.
" @Revision:    0.0.24

let s:save_cpo = &cpo
set cpo&vim


function! trag#java#Rename(world, selected, from, to) "{{{3
    return trag#rename#Rename(a:world, a:selected, a:from, a:to, suffix)
endf


let &cpo = s:save_cpo
unlet s:save_cpo
