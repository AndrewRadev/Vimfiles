" rename.vim
" @Author:      Thomas Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2009-02-27.
" @Last Change: 2009-02-27.
" @Revision:    0.0.3

let s:save_cpo = &cpo
set cpo&vim


function! trag#rename#Rename(world, selected, from, to, suffix) "{{{3
    let rv = trag#general#Rename(a:world, a:selected, a:from, a:to)
    let from_file = a:from . a:suffix
    let to_file = a:to . a:suffix
    let bnr = bufnr(from_file)
    " TLogVAR from_file, to_file, bnr
    if filereadable(to_file)
        echom 'TRag: Cannot rename file, file already exists: '. to_file
    elseif filereadable(from_file)
        call rename(from_file, to_file)
        echom 'TRag: Renamed file '. from_file .' -> '. to_file
    endif
    if bnr != -1
        if bufnr(to_file) != -1
            call tlib#notify#Echo('TRag: Cannot rename buffer, buffer already exists: '. to_file, 'Error')
        else
            exec 'buffer '. bnr
            exec 'file! '. fnameescape(to_file)
            w!
            echom 'TRag: Renamed buffer '. from_file .' -> '. to_file
            if filereadable(from_file) && !filereadable(to_file)
                call tlib#notify#Echo('TRag: Inconsistent state. Please rename the file '. from_file .' -> '. to_file, 'Error')
            endif
        endif
    endif
    return rv
endf


let &cpo = s:save_cpo
unlet s:save_cpo
