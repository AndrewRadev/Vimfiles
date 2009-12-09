" autocmdgroup.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2008-08-19.
" @Last Change: 2009-12-07.
" @Revision:    0.0.5

if &cp || exists("loaded_tlib_autocmdgroup_autoload")
    finish
endif
let loaded_tlib_autocmdgroup_autoload = 1
let s:save_cpo = &cpo
set cpo&vim


augroup TLib
    autocmd!
augroup END


function! tlib#autocmdgroup#Init() "{{{3
endf


let &cpo = s:save_cpo
unlet s:save_cpo
