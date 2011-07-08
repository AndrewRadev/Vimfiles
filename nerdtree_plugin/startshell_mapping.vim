call NERDTreeAddKeyMap({
            \ 'key': 'S',
            \ 'callback': 'NERDTreeStartShell',
            \ 'quickhelpText': 'start a :shell in this dir' })

function! NERDTreeStartShell()
    let n = g:NERDTreeDirNode.GetSelected()

    let oldCWD = getcwd()
    try
        exec 'lcd ' . n.path.str({'format': 'Cd'})
        redraw!
        shell
    finally
        exec 'lcd ' . oldCWD
    endtry
endfunction
