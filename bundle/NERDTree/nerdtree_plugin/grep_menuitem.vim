if exists("g:loaded_nerdtree_grep_menuitem")
    finish
endif
let g:loaded_nerdtree_grep_menuitem = 1

if !executable("grep")
    finish
endif

call NERDTreeAddMenuItem({
    \ 'text': '(g)rep directory',
    \ 'shortcut': 'g',
    \ 'callback': 'NERDTreeGrepMenuItem' })

function! NERDTreeGrepMenuItem()
    let n = g:NERDTreeDirNode.GetSelected()

    let pattern = input("Search Pattern: ")
    if pattern == ''
        return
    endif

    "use the previous window to jump to the first search result
    wincmd w


    let old_shellpipe = &shellpipe

    try
        "a hack for *nix to ensure the grep output isnt echoed in vim
        let &shellpipe='&>'

        exec 'silent grep -r ' . pattern . ' ' . n.path.str()
    finally
        let &shellpipe = old_shellpipe
    endtry

    let hits = len(getqflist())
    if hits == 0
        redraw
        echo "No hits"
    elseif hits > 1
        copen
        wincmd p
    endif
    redraw!
endfunction
