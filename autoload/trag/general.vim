" general.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-12-01.
" @Last Change: 2009-02-25.
" @Revision:    0.0.15

let s:save_cpo = &cpo
set cpo&vim


function! trag#general#Rename(world, selected, rx, subst) "{{{3
    let cmd = 's/\C\<'. escape(tlib#rx#Escape(a:rx), '/') .'\>/'. escape(tlib#rx#EscapeReplace(a:subst), '/') .'/ge'
    " let cmd = 's/\C'. escape(a:rx, '/') .'/'. escape(tlib#rx#EscapeReplace(a:subst), '/') .'/ge'
    return trag#RunCmdOnSelected(a:world, a:selected, cmd)
endf


let &cpo = s:save_cpo
unlet s:save_cpo
